import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";

import { Test } from "../../src/classes/test";
import { Comment } from "../../src/classes/comment";
import { CommentDocument, CategoryDocument, PostDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

let totalPosts: Array<PostDocument> = [];

let category: CategoryDocument;
let newCategory: CategoryDocument;

describe("Post list test", () => {
  it("Create some posts for test", async () => {
    // create 31 posts.
    category = await Test.createCategory();
    for (let i = 1; i <= 10; i++) {
      await Post.create({
        uid: "test-uid",
        category: category.id,
        title: "test-title-" + i,
      } as any);
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  });

  it("Get first page.", async () => {
    totalPosts = await Post.list({
      limit: "4",
    });

    // console.log(totalPosts[0]);
    for (let i = 0; i <= 3; i++) {
      expect(totalPosts[i])
          .to.be.an("object")
          .to.have.property("title")
          .equals("test-title-" + (10 - i));
    }
  });

  it("Get second page.", async () => {
    const posts = await Post.list({
      startAfter: totalPosts[totalPosts.length - 1].createdAt.toString(),
      limit: "4",
    });
    for (let i = 0; i <= 3; i++) {
      expect(posts[i])
          .to.be.an("object")
          .to.have.property("title")
          .equals("test-title-" + (6 - i));
    }
    totalPosts = [...totalPosts, ...posts];
  });

  it("Get third page.", async () => {
    const posts = await Post.list({
      category: category.id, // without category, it will include 9 more posts.
      startAfter: totalPosts[totalPosts.length - 1].createdAt.toString(),
      limit: "4",
    });

    expect(posts.length).is.equals(2);

    expect(posts[0]).to.be.an("object").to.have.property("title").equals("test-title-2");
    expect(posts[1]).to.be.an("object").to.have.property("title").equals("test-title-1");

    totalPosts = [...totalPosts, ...posts];
    expect(totalPosts.length).equals(10);
  });

  it("Gets data from unknown category.", async () => {
    const posts = await Post.list({
      category: "someCategory",
    });

    expect(posts.length).equals(0);
  });

  it("Gets data from new category category.", async () => {
    newCategory = await Test.createCategory();
    for (let i = 1; i <= 2; i++) {
      await Post.create({
        uid: "test-uid",
        category: newCategory.id,
        title: "test-title-x-" + i,
      } as any);
    }

    const posts = await Post.list({
      category: newCategory.id,
    });

    expect(posts.length).equals(2);
  });

  it("Gets data from all category.", async () => {
    const posts = await Post.list({});

    expect(posts[0]).to.be.an("object").to.have.property("title").equals("test-title-x-2");
    expect(posts[1]).to.be.an("object").to.have.property("title").equals("test-title-x-1");
    expect(posts[2]).to.be.an("object").to.have.property("title").equals("test-title-10");
  });

  it("Gets limited number of posts", async () => {
    const q1 = await Post.list({
      limit: "5",
    });
    expect(q1.length).equals(5);
    const q2 = await Post.list({
      limit: "2",
    });
    expect(q2.length).equals(2);
    const q3 = await Post.list({
      limit: "7",
    });
    expect(q3.length).equals(7);
  });

  it("test listing content option", async () => {
    // Includes post content by default.
    let re = await Post.list({
      category: "qna",
      limit: "1",
    });
    expect("content" in re[0] === true).true;

    // Includes post'content.
    re = await Post.list({
      category: "qna",
      limit: "1",
      content: "Y",
    });
    expect("content" in re[0] === true).true;

    // Do not include post content.
    re = await Post.list({
      category: "qna",
      limit: "1",
      content: "N",
    });
    expect("content" in re[0] === false).true;
  });

  it("test listing author option", async () => {
    // Includes post content by default.
    let re = await Post.list({
      category: "qna",
      limit: "1",
    });
    expect("author" in re[0]).true;
    expect("authorLevel" in re[0]).true;
    expect("authorPhotoUrl" in re[0]).true;

    // Includes post'content.
    re = await Post.list({
      category: "qna",
      limit: "1",
      author: "Y",
    });
    expect("author" in re[0]).true;
    expect("authorLevel" in re[0]).true;
    expect("authorPhotoUrl" in re[0]).true;

    // Do not include post content.
    re = await Post.list({
      category: "qna",
      limit: "1",
      author: "N",
    });
    expect("author" in re[0]).false;
    expect("authorLevel" in re[0]).false;
    expect("authorPhotoUrl" in re[0]).false;
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
    const listA = await Post.list({
      category: cat.id,
      limit: "1",
      author: "N",
    });

    // There should be no last comment property.
    expect("lastComment" in listA[0]).false;

    // Get last comment
    const listB = await Post.list({
      category: cat.id,
      limit: "1",
      author: "N",
      lastComment: "Y",
    });

    // There should be last comment property.
    expect("lastComment" in listB[0]).true;
    // Last comment should be the same as the second created comment.
    expect(listB[0].lastComment?.id === secondComment.id).true;

    // cleanup
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
    const listA = await Post.list({
      category: cat.id,
      author: "N",
    });
    expect(listA.length === 2).true;

    // list posts with photo only
    const listB = await Post.list({
      category: cat.id,
      author: "N",
      photo: "Y",
    });
    expect(listB.length === 1).true;
    expect(listB[0].id === postB.id).true;

    // create one more test post with photo
    const postC = await Post.create({
      uid: "test-uid",
      category: cat.id,
      title: "test-title-x-" + Date.now(),
      files: ["https://someimage.png", "https://someimage2.jpg"],
    } as any);

    // list posts with photo only
    const listC = await Post.list({
      category: cat.id,
      author: "N",
      photo: "Y",
    });
    expect(listC.length === 2).true;

    // cleanup
    Post.delete({ id: postA.id!, uid: "test-uid" });
    Post.delete({ id: postB.id!, uid: "test-uid" });
    Post.delete({ id: postC.id!, uid: "test-uid" });
  });
});

