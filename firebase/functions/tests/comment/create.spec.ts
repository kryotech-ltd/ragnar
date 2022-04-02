import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Comment } from "../../src/classes/comment";
// import { ERROR_EMPTY_CATEGORY, ERROR_EMPTY_UID } from "../../src/defines";

new FirebaseAppInitializer();

describe("comment create test", () => {
  it("Succed to create a comment", async () => {
    const comment = await Comment.create({
      uid: "a",
      postId: "comment-id",
      parentId: "parent-id",
      content: "yo",
    } as any);
    // console.log(comment);
    expect(comment).not.to.be.null;
    expect(comment).to.be.an("object").to.have.property("id").to.be.string;
    expect(comment!.uid).equals("a");
  });
});
