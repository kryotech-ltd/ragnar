import * as admin from "firebase-admin";

export interface CategoryDocument {
  id?: string;
  timestamp?: number;
  order: number;
  title: string;
  description: string;
  backgroundColor?: string;
  foregroundColor?: string;
}

/**
 * Post document class for multi purpose.
 *
 * This can be used as a type like below.
 *
 * ```ts
 * const post = res2.data as PostDocument;
 * ```
 */
export class PostDocument {
  id = "";
  uid = "";
  category = "";
  subcategory?: string;
  title?: string;
  content?: string;
  summary?: string;
  files?: string[];
  hasPhoto = false;
  deleted = false;
  noOfComments = 0;
  year = 0;
  month = 0;
  day = 0;
  dayOfYear = 0;
  week = 0;
  createdAt?: admin.firestore.FieldValue;
  updatedAt?: admin.firestore.FieldValue;
  point = 0;

  fromDocument(doc: any, id: string): PostDocument {
    const obj = doc as PostDocument;

    obj.id = id;
    obj.uid = doc.uid;
    obj.category = doc.category;
    obj.subcategory = doc.subcategory ?? "";
    obj.title = doc.title ?? "";
    obj.content = doc.content ?? "";
    obj.subcategory = doc.content ?? "";
    obj.files = doc.files ?? [];
    obj.hasPhoto = doc.hasPhoto;
    obj.deleted = doc.deleted;
    obj.noOfComments = doc.noOfComment;
    obj.year = doc.year;
    obj.month = doc.month;
    obj.day = doc.day;
    obj.dayOfYear = doc.dayOfYear;
    obj.week = doc.week;
    obj.createdAt = doc.createdAt;
    obj.updatedAt = doc.updatedAt;
    obj.point = doc.point ?? 0;

    return obj;
  }
}

/**
 * Minimum
 */
// export interface PostCreateParams {
//   uid: string;
//   category: string;
//   subcategory?: string;
//   title?: string;
//   content?: string;
//   summary?: string;
//   files?: string[];
// }

// export interface PostCreateRequirements {
//   uid: string;
//   category: string;
//   subcategory?: string;
//   title?: string;
//   content?: string;
//   summary?: string;
//   files: string[];
//   hasPhoto: boolean;
//   deleted: false;
//   noOfComment: 0;
//   year: number;
//   month: number;
//   day: number;
//   dayOfYear: number;
//   week: number;
//   createdAt: admin.firestore.FieldValue;
//   updatedAt: admin.firestore.FieldValue;
// }

/**
 * A multi-purpose comment document interface representing the comment document of firebase.
 *
 */
export class CommentDocument {
  id = "";
  uid = "";
  postId = "";
  parentId = "";
  content = "";
  files: string[] = [];
  hasPhoto = false;
  deleted = false;
  createdAt?: admin.firestore.FieldValue;
  updatedAt?: admin.firestore.FieldValue;
  point = 0;

  fromDocument(data: any, id: string): CommentDocument {
    const obj = new CommentDocument();

    obj.id = id;
    obj.uid = data.uid;
    obj.postId = data.postId;
    obj.parentId = data.parentId;
    obj.content = data.content;
    obj.files = data.files ?? [];
    obj.hasPhoto = data.hasPhoto;
    obj.deleted = data.deleted;
    obj.createdAt = data.createdAt;
    obj.updatedAt = data.updatedAt;
    obj.point = data.point ?? 0;

    return obj;
  }
}

/**
 * For passing parameters only on creating comment.
 */
export interface CommentCreateParams {
  uid: string;
  postId: string;
  parentId?: string;
  content?: string;
  files?: string[];
}

/**
 * To create a comment, it needs the complete data model.
 * Use this to create a comment.
 */
export interface CommentCreateRequirements {
  uid: string;
  postId: string;
  parentId: string;
  content: string;
  files: string[];
  hasPhoto: boolean;
  deleted: false;
  createdAt: admin.firestore.FieldValue;
  updatedAt: admin.firestore.FieldValue;
}
