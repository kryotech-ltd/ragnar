import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Comment } from "../../src/classes/comment";
import {
  ERROR_ALREADY_DELETED,
  ERROR_COMMENT_NOT_EXISTS,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_UID,
  ERROR_NOT_YOUR_COMMENT,
} from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { CommentDocument } from "../../src/interfaces/forum.interface";
import { Storage } from "../../src/classes/storage";

new FirebaseAppInitializer();

let comment: CommentDocument | null;
const uid = "test-uid-" + Utils.getTimestamp();

describe("comment delete test", () => {
  it("Prepares to create a comment for testing", async () => {
    comment = await Comment.create({
      uid: uid,
      postId: "comment-id",
      parentId: "parent-id",
      content: "yo",
    } as any);

    expect(comment).to.be.an("object");
  });

  it("fail - empty id", async () => {
    try {
      await Comment.delete({} as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_ID);
    }
  });

  it("fail - empty uid", async () => {
    try {
      await Comment.delete({ id: "someId" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_UID);
    }
  });

  it("fail - comment not existing", async () => {
    try {
      await Comment.delete({ id: "non-existing-id", uid: "some-uid" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_COMMENT_NOT_EXISTS);
    }
  });

  it("fail - wrong uid", async () => {
    try {
      await Comment.delete({ id: comment!.id, uid: "some-uid" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_COMMENT);
    }
  });

  it("success - comment deleted (mark as deleted)", async () => {
    const res = await Comment.delete({ id: comment!.id, uid: uid } as any);
    expect(res.id).equals(comment!.id);

    const commentDoc = await Comment.get(comment!.id);
    expect(commentDoc!.deleted).true;
  });

  it("fail - already deleted", async () => {
    try {
      await Comment.delete({ id: comment!.id, uid: uid } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_ALREADY_DELETED);
    }
  });

  it("success - create and delete comment with files", async () => {
    const filename = "uploads/delete-test-" + Utils.getTimestamp();

    // references
    const file = await Storage.upload("./tests/storage/test.jpg", filename + ".jpg");
    const thumb = Storage.getRefFromPath(filename + "_200x200.webp");

    // create comment with file
    const comment = await Comment.create({ uid: uid, files: [file.publicUrl()] } as any);
    expect(comment).to.be.an("object").to.have.property("files").lengthOf(1);
    expect((await file.exists())[0]).true;
    await Utils.delay(2000);
    expect((await thumb.exists())[0]).true;

    // delete comment
    const res = await Comment.delete({ id: comment!.id, uid: uid });
    expect(res.id).equals(comment!.id);
    expect((await file.exists())[0]).false;
    expect((await thumb.exists())[0]).false;
  });
});
