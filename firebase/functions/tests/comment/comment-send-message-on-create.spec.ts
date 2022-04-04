import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { Utils } from "../../src/classes/utils";
import { Comment } from "../../src/classes/comment";
import { User } from "../../src/classes/user";
import { Messaging } from "../../src/classes/messaging";
import { Ref } from "../../src/classes/ref";

new FirebaseAppInitializer();

describe("Send message on comment create test", () => {
  it("Sende Message on comment create", async () => {
    const stamp = Utils.getTimestamp();
    const a = "uc-a-" + stamp;
    const b = "uc-b-" + stamp;
    const c = "uc-c-" + stamp;

    await User.create(a, { firstName: "uc-" + stamp });
    await User.create(b, { firstName: "uc-" + stamp });
    await User.create(c, { firstName: "uc-" + stamp });

    const post = await Post.create({
      uid: a,
      category: "cat1",
      title: "oncreateCommentTest",
    } as any);

    const comment1 = await Comment.create({
      uid: b,
      postId: post!.id,
      parentId: post!.id,
      content: "first",
    } as any);

    const comment2 = await Comment.create({
      uid: c,
      postId: post!.id,
      parentId: comment1!.id,
      content: "second",
    } as any);

    // get comment ancestors
    const ancestorsUid = await Post.getCommentAncestors(comment2!.id, comment2!.uid);
    expect(ancestorsUid).include(comment1!.uid);

    // add the post uid if the comment author is not the post author
    if (post!.uid != comment2!.uid && !ancestorsUid.includes(post!.uid)) {
      ancestorsUid.push(post!.uid);
    }

    expect(ancestorsUid).include(post!.uid);
    const topic = "comments_" + post!.category;
    // Don't send the same message twice to topic subscribers and comment notifyees.
    const userUids = await Messaging.getCommentNotifyeeWithoutTopicSubscriber(ancestorsUid.join(","), topic);

    // get users tokens
    const tokens = await Messaging.getTokensFromUids(userUids.join(","));
    expect(tokens).is.empty;

    const res1 = await Post.sendMessageOnCommentCreate(comment2!);
    if (res1) {
      expect(res1.topicResponse).not.empty.include("/project");
      expect(res1.tokenResponse.success).equal(0);
      expect(res1.tokenResponse.error).equal(0);
    } else {
      expect.fail("must not be null1");
    }

    await Messaging.updateToken(a, "fake-token-1");
    await Messaging.updateToken(b, "fake-token-2");
    const res2 = await Post.sendMessageOnCommentCreate(comment2!);
    if (res2) {
      expect(res2.topicResponse).not.empty.include("/project");
      expect(res2.tokenResponse.success).equal(0);
      expect(res2.tokenResponse.error).equal(2);
    } else {
      expect.fail("must not be null2,");
    }

    await Messaging.updateToken(a, "fake-token-1");
    await Messaging.updateToken(b, "fake-token-2");
    await Ref.userSetting(b, "topic").set({ ["comments_" + post!.category]: true });
    const res3 = await Post.sendMessageOnCommentCreate(comment2!);
    if (res3) {
      expect(res3.topicResponse).not.empty.include("/project");
      expect(res3.tokenResponse.success).equal(0);
      expect(res3.tokenResponse.error).equal(1);
    } else {
      expect.fail("must not be null3,");
    }
  });
});
