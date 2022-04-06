"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Post = void 0;
const admin = require("firebase-admin");
const dayjs = require("dayjs");
const dayOfYear = require("dayjs/plugin/dayOfYear");
const weekOfYear = require("dayjs/plugin/weekOfYear");
dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);
const ref_1 = require("./ref");
const defines_1 = require("../defines");
const messaging_1 = require("./messaging");
class Post {
    /**
     *
     * @see README.md for details.
     * @param data post doc data to be created
     * @returns
     * - post doc as in PostDocument interface after create. Note that, it will contain post id.
     * - Or empty map object if it fails somehow on creating.
     * @note exception will be thrown on error.
     */
    static async create(data) {
        // check up
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        if (!data.category)
            throw defines_1.ERROR_EMPTY_CATEGORY;
        // get all the data from client.
        const doc = data;
        // default data
        doc.hasPhoto = !!doc.files;
        doc.deleted = false;
        doc.noOfComments = 0;
        doc.year = dayjs().year();
        doc.month = dayjs().month() + 1;
        doc.day = dayjs().date();
        doc.dayOfYear = dayjs().dayOfYear();
        doc.week = dayjs().week();
        doc.createdAt = admin.firestore.FieldValue.serverTimestamp();
        doc.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        // create post
        const ref = await ref_1.Ref.postCol.add(doc);
        // return the document object of newly created post.
        const snapshot = await ref.get();
        if (snapshot.exists) {
            const postData = snapshot.data();
            postData.id = ref.id;
            return postData;
        }
        else {
            return {};
        }
    }
    /**
     * Updates a post
     * @param data data to update the post
     * - data.id as post id is required.
     * - data.uid as post owner's uid is required.
     * @returns the post as PostDocument
     */
    static async update(data) {
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        const post = await this.get(data.id);
        if (post === null)
            throw defines_1.ERROR_POST_NOT_EXIST;
        if (post.uid !== data.uid)
            throw defines_1.ERROR_NOT_YOUR_POST;
        const id = data.id;
        delete data.id;
        data.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        if (data.files && data.files.length) {
            data.hasPhoto = true;
        }
        else {
            data.hasPhoto = false;
        }
        await ref_1.Ref.postDoc(id).update(data);
        return await this.get(id);
    }
    /**
     * Returns a post as PostDocument or null if the post does not exists.
     * @param id post id
     * @returns post document or null
     */
    static async get(id) {
        const snapshot = await ref_1.Ref.postDoc(id).get();
        if (snapshot.exists) {
            // return snapshot.data() as PostDocument;
            const data = snapshot.data();
            if (data) {
                data.id = id;
                return data;
            }
        }
        return null;
    }
    static async sendMessageOnPostCreate(data, id) {
        var _a, _b;
        const category = data.category;
        const payload = messaging_1.Messaging.topicPayload("posts_" + category, {
            title: (_a = data.title) !== null && _a !== void 0 ? _a : "",
            body: (_b = data.content) !== null && _b !== void 0 ? _b : "",
            postId: id,
            type: "post",
            uid: data.uid,
        });
        return admin.messaging().send(payload);
    }
    static async sendMessageOnCommentCreate(data) {
        const post = await this.get(data.postId);
        if (!post)
            return null;
        const messageData = {
            title: "New Comment: ",
            body: post.content,
            postId: data.postId,
            type: "post",
            uid: data.uid,
        };
        // console.log(messageData);
        const topic = "comments_" + post.category;
        // send push notification to topics
        const sendToTopicRes = await admin.messaging().send(messaging_1.Messaging.topicPayload(topic, messageData));
        // get comment ancestors
        const ancestorsUid = await Post.getCommentAncestors(data.id, data.uid);
        // add the post uid if the comment author is not the post author
        if (post.uid != data.uid && !ancestorsUid.includes(post.uid)) {
            ancestorsUid.push(post.uid);
        }
        // Don't send the same message twice to topic subscribers and comment notifyees.
        const userUids = await messaging_1.Messaging.getCommentNotifyeeWithoutTopicSubscriber(ancestorsUid.join(","), topic);
        // get users tokens
        const tokens = await messaging_1.Messaging.getTokensFromUids(userUids.join(","));
        const sendToTokenRes = await messaging_1.Messaging.sendingMessageToTokens(tokens, messaging_1.Messaging.preMessagePayload(messageData));
        return {
            topicResponse: sendToTopicRes,
            tokenResponse: sendToTokenRes,
        };
    }
    // get comment ancestor by getting parent comment until it reach the root comment
    // return the uids of the author
    static async getCommentAncestors(id, authorUid) {
        const c = await ref_1.Ref.commentDoc(id).get();
        let comment = c.data();
        const uids = [];
        while (comment.postId != comment.parentId) {
            const com = await ref_1.Ref.commentDoc(comment.parentId).get();
            if (!com.exists)
                continue;
            comment = com.data();
            if (comment.uid == authorUid)
                continue; // skip the author's uid.
            uids.push(comment.uid);
        }
        return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
    }
}
exports.Post = Post;
//# sourceMappingURL=post.js.map