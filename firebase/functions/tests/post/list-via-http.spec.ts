import axios from "axios";
import "mocha";
import { expect } from "chai";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Test } from "../../src/classes/test";
import { Post } from "../../src/classes/post";
import { Comment } from "../../src/classes/comment";
import { CommentDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postList";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postList";
describe("Post list test", () => {
  it("test listing content option", async () => {
    // Includes post content by default.
    let res = await axios.post(endpoint, { category: "qna", limit: 1 });
    expect("content" in res.data[0] === true).true;

    // Includes post'content.
    res = await axios.post(endpoint, { category: "qna", limit: 1, content: "Y" });
    expect("content" in res.data[0] === true).true;

    // Do not include post content.
    res = await axios.post(endpoint, { category: "qna", limit: 1, content: "N" });
    expect("content" in res.data[0] === false).true;
  });

  it("test listing author option", async () => {
    // Includes post author by default.
    let res = await axios.post(endpoint, { category: "qna", limit: 1 });
    expect("author" in res.data[0] === true).true;
    expect("authorLevel" in res.data[0] === true).true;
    expect("authorPhotoUrl" in res.data[0] === true).true;

    // Includes post author information.
    res = await axios.post(endpoint, { category: "qna", limit: 1, author: "Y" });
    expect("author" in res.data[0] === true).true;
    expect("authorLevel" in res.data[0] === true).true;
    expect("authorPhotoUrl" in res.data[0] === true).true;

    // Do not include post author information.
    res = await axios.post(endpoint, { category: "qna", limit: 1, author: "N" });
    expect("author" in res.data[0] === false).true;
    expect("authorLevel" in res.data[0] === false).true;
    expect("authorPhotoUrl" in res.data[0] === false).true;
  });

  it("test listing lastComment option", async () => {
    // create test post with comment
    const cat = await Test.createCategory();
    const post = await Post.create({
      uid: "test-uid",
      category: cat.id,
      title: "test-title-x-" + Date.now(),
    } as any);

    // create 2 comments
    const firstComment = await Comment.create({
      uid: "test-uid",
      postId: post.id,
      parentId: post.id,
      content: "first comment",
    } as CommentDocument);
    await Utils.delay(1000);

    const secondComment = await Comment.create({
      uid: "test-uid",
      postId: post.id,
      parentId: post.id,
      content: "second comment",
    } as CommentDocument);
    await Utils.delay(1000);

    // get list
    // By default no last comment.
    const listA = await axios.post(endpoint, { category: cat.id, limit: 1, author: "N" });

    // There should be no last comment property.
    expect("lastComment" in listA.data[0]).false;

    // Get last comment
    const listB = await axios.post(endpoint, { category: cat.id, limit: 1, author: "N", lastComment: "Y" });

    // There should be last comment property.
    expect("lastComment" in listB.data[0]).true;
    // Last comment should be the same as the second created comment.
    expect(listB.data[0].lastComment?.id === secondComment.id).true;

    // / cleanup
    Comment.delete({ id: firstComment.id, uid: "test-uid" });
    Comment.delete({ id: secondComment.id, uid: "test-uid" });
    Post.delete({ id: post.id!, uid: "test-uid" });
  });

  it("test listing photo option", async () => {
    const cat = await Test.createCategory();

    // create test post without photo
    const postA = await Post.create({
      uid: "test-uid",
      category: cat.id,
      title: "test-title-x-" + Date.now(),
    } as any);

    // create test post with photo
    const postB = await Post.create({
      uid: "test-uid",
      category: cat.id,
      title: "test-title-x-" + Date.now(),
      files: ["https://someimage.png", "https://someimage2.jpg"],
    } as any);

    // list all posts (will return all post by default)
    const listA = await axios.post(endpoint, { category: cat.id, limit: 10, author: "N" });
    expect(listA.data.length === 2).true;

    // list posts with photo only
    const listB = await axios.post(endpoint, { category: cat.id, limit: 10, author: "N", photo: "Y" });
    expect(listB.data.length === 1).true;
    expect(listB.data[0].id === postB.id).true;

    // cleanup
    Post.delete({ id: postA.id!, uid: "test-uid" });
    Post.delete({ id: postB.id!, uid: "test-uid" });
  });
});

