import { Utils } from "./utils";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { MeiliSearch as Meili, SearchParams, SearchResponse } from "meilisearch";

/**
 * TODO: Test
 * - indexPostDocument
 * - deleteIndexedPostDocument
 * - indexCommentDocument
 * - deleteIndexedCommentDocument
 * - indexUserDocument
 * - deleteIndexedUserDocument
 */
export class Meilisearch {
  static excludedCategories = ["quiz"];

  static client = new Meili({
    host: "http://wonderfulkorea.kr:7700",
  });

  /**
   * Index
   * @param data data to be index
   * @return Promise<any>
   */
  static indexForumDocument(data: PostDocument | CommentDocument): Promise<any> {
    return this.client.index("posts-and-comments").addDocuments([data]);
  }

  /**
   *
   * @param id document ID to delete
   * @return Promise
   */
  static deleteIndexedForumDocument(id: string) {
    return this.client.index("posts-and-comments").deleteDocument(id);
  }

  /**
   * Creates a post document index.
   *
   * @param data post data to index
   * @param context context
   * @return Promise
   */
  static async indexPostCreate(data: PostDocument, context: any) {
    if (this.excludedCategories.includes(data.category)) return null;

    const _data: PostDocument = {
      id: context.params.id,
      uid: data.uid,
      title: data.title ?? "",
      category: data.category,
      content: Utils.removeHtmlTags(data.content),
      files: Array.isArray(data.files) ? data.files.join(",") : data.files,
      noOfComments: data.noOfComments ?? 0,
      deleted: data.deleted ? "Y" : "N",
      createdAt: Utils.getTimestamp(data.createdAt),
      updatedAt: Utils.getTimestamp(data.updatedAt),
    };

    const promises = [];

    promises.push(this.client.index("posts").addDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Update a post document index.
   *
   * @param data post data to index
   * @param context context
   * @return Promise
   */
  static async indexPostUpdate(data: { before: PostDocument; after: PostDocument }, context: any) {
    if (this.excludedCategories.includes(data.after.category)) return null;
    if (data.before.title === data.after.title && data.before.content === data.after.content) {
      return null;
    }

    const after = data.after;

    const _data: PostDocument = {
      id: context.params.id,
      uid: after.uid,
      title: after.title ?? "",
      category: after.category,
      content: Utils.removeHtmlTags(after.content),
      files: Array.isArray(after.files) ? after.files.join(",") : after.files,
      noOfComments: after.noOfComments ?? 0,
      deleted: after.deleted ? "Y" : "N",
      updatedAt: Utils.getTimestamp(after.updatedAt),
    };

    const promises = [];

    promises.push(this.client.index("posts").updateDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Deletes indexed post document.
   *
   * @param context Post ID of the document to be deleted.
   * @return Promise
   */
  static async deleteIndexedPostDocument(context: any) {
    const id = context.params.id;

    const promises = [];
    promises.push(this.client.index("posts").deleteDocument(id));
    promises.push(this.deleteIndexedForumDocument(id));
    return Promise.all(promises);
  }

  /**
   * Creates a comment document index.
   *
   * @param data Document data
   * @param context Event context
   * @return Promise
   */
  static async indexCommentCreate(data: CommentDocument, context: any) {
    const _data = {
      id: context.params.id,
      uid: data.uid,
      postId: data.postId,
      parentId: data.parentId,
      content: Utils.removeHtmlTags(data.content) ?? "",
      files: Array.isArray(data.files) ? data.files.join(",") : data.files,
      createdAt: Utils.getTimestamp(data.createdAt),
      updatedAt: Utils.getTimestamp(data.updatedAt),
    };

    const promises = [];

    promises.push(this.client.index("comments").addDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Updates a comment document index.
   *
   * @param data Document data
   * @param context Event context
   * @return Promise
   */
  static async indexCommentUpdate(data: { before: CommentDocument; after: CommentDocument }, context: any) {
    if (data.before.content === data.after.content) return null;

    const after = data.after;

    const _data: CommentDocument = {
      id: context.params.id,
      uid: after.uid,
      postId: after.postId,
      parentId: after.parentId,
      content: Utils.removeHtmlTags(after.content),
      files: Array.isArray(after.files) ? after.files.join(",") : after.files,
      updatedAt: Utils.getTimestamp(after.updatedAt),
    };

    const promises = [];

    promises.push(this.client.index("comments").updateDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Deletes indexed comment document.
   *
   * @param id Comment ID of the document to be deleted.
   * @return Promise
   */
  static async deleteIndexedCommentDocument(id: string) {
    const promises = [];
    promises.push(this.client.index("comments").deleteDocument(id));
    // promises.push(axios.delete("http://wonderfulkorea.kr:7700/indexes/comments/documents/" + id));
    promises.push(this.deleteIndexedForumDocument(id));
    return Promise.all(promises);
  }

  /**
   * Creates or update a user document index.
   *
   * @param {*} uid user id.
   * @param {*} data user data to index.
   * @return promise
   */
  static async indexUserDocument(uid: string, data: any = {}): Promise<any> {
    const _data = {
      id: uid,
      gender: data.gender ?? "",
      firstName: data.firstName ?? "",
      middleName: data.middleName ?? "",
      lastName: data.lastName ?? "",
      photoUrl: data.photoUrl ?? "",
    };

    return this.client.index("users").addDocuments([_data]);
    // return axios.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data);
  }

  /**
   * Deletes user related documents on realtime database and meilisearch indexing.
   *
   * @param {*} uid user id to delete.
   * @return promise
   */
  static async deleteIndexedUserDocument(uid: string) {
    const promises = [];

    // Remove user data under it's uid from:
    // - 'users' and 'user-settings' realtime database,
    // - 'quiz-history' firestore database.
    // promises.push(rdb.ref("users").child(uid).remove());
    // promises.push(rdb.ref("user-settings").child(uid).remove());
    // promises.push(db.collection("quiz-history").doc(uid).delete());
    promises.push(this.client.index("users").deleteDocument(uid));
    return Promise.all(promises);
  }

  /**
   * Search
   * 
   * @param index 
   * @param data search options
   * @returns Search result
   */
  static async search(
    index: string,
    data: { keyword?: string; searchOptions?: SearchParams }
  ): Promise<SearchResponse<Record<string, any>>> {
    return this.client.index(index).search(data.keyword, data.searchOptions);
  }

  // FOR TESTING
  // TODO: move this code somewhere else.
  static createTestPostDocument(data: { id: string; uid?: string; title?: string; content?: string }): PostDocument {
    return {
      id: data.id,
      uid: data.uid ?? "test-uid",
      title: data.title ?? `${data.id} title`,
      content: data.content ?? `${data.id} content`,
      category: "test-cat",
    };
  }
}
