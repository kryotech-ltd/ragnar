"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const defines_1 = require("../defines");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
const admin = require("firebase-admin");
const setting_1 = require("./setting");
// import { GetUsersResult } from "firebase-admin/lib/auth/base-auth";
// import { ErrorCodeMessage } from "../interfaces/common.interface";
class User {
    static get auth() {
        return admin.auth();
    }
    /**
     * Update (Not create or set) the profile document.
     * @param uid uid of the user
     * @param data data to update as the user profile
     */
    static async create(uid, data) {
        data.updatedAt = utils_1.Utils.getTimestamp();
        data.registeredAt = utils_1.Utils.getTimestamp();
        data.profileReady = 90000000000000;
        return ref_1.Ref.userDoc(uid).update(data);
    }
    /**
     * Authenticates user with id and password.
     * @param data input data that has uid and password
     * @returns Error string on error(not throwing as an exception). Empty string on success.
     *
     * ! `data.password` uses user's `registeredAt`. And this will be removed on Jul.
     */
    static async authenticate(data) {
        if (!data.uid) {
            return defines_1.ERROR_EMPTY_UID;
        }
        else if (!data.password && !data.password2) {
            return defines_1.ERROR_EMPTY_PASSWORD;
        }
        // console.log("data; ", data);
        // Check if user exists.
        const user = await this.get(data.uid);
        if (user === null) {
            return defines_1.ERROR_USER_NOT_FOUND;
        }
        if (data.password) {
            const password = this.generatePassword(user);
            if (password === data.password)
                return "";
            else
                return defines_1.ERROR_WRONG_PASSWORD;
        }
        else {
            // password version 2.
            const passwordDb = await setting_1.Setting.value(data.uid, "password");
            // console.log("passwordDb; ", passwordDb);
            return data.password2 == passwordDb ? "" : defines_1.ERROR_WRONG_PASSWORD;
        }
    }
    /**
     * Returns user document as in User class
     * @param uid uid of user
     * @returns user document or empty map.
     */
    static async get(uid) {
        const snapshot = await ref_1.Ref.userDoc(uid).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            val.id = uid;
            return val;
        }
        return null;
    }
    /**
     *
     * @param uid
     */
    static async isAdmin(uid) {
        if (!uid)
            return false;
        const doc = await ref_1.Ref.adminDoc.get();
        const admins = doc.data();
        if (!admins)
            return false;
        if (!admins[uid])
            return false;
        return true;
    }
    static async enableUser(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: defines_1.ERROR_YOU_ARE_NOT_ADMIN,
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        try {
            const user = await this.auth.updateUser(data.uid, { disabled: false });
            if (user.disabled == false)
                await ref_1.Ref.users.child(data.uid).update({ disabled: false });
            return user;
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    static async disableUser(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: defines_1.ERROR_YOU_ARE_NOT_ADMIN,
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        try {
            const user = await this.auth.updateUser(data.uid, { disabled: true });
            if (user.disabled == true)
                await ref_1.Ref.users.child(data.uid).update({ disabled: true });
            return user;
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    // https://firebase.google.com/docs/auth/admin/manage-users#bulk_retrieve_user_data
    static async adminUserSearch(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: defines_1.ERROR_YOU_ARE_NOT_ADMIN,
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        if (!data.email && !data.phoneNumber)
            return defines_1.ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER;
        if (data.email && data.phoneNumber)
            return defines_1.ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY;
        const req = [];
        req.push(data);
        // console.log(req);
        try {
            const result = await this.auth.getUsers(req);
            // result.users.forEach((userRecord) => {
            //   console.log(userRecord);
            // });
            // // console.log("Unable to find users corresponding to these identifiers:");
            // result.notFound.forEach((userIdentifier) => {
            //   console.log(userIdentifier);
            // });
            if (result.users.length == 0)
                return defines_1.ERROR_USER_AUTH_NOT_FOUND;
            const user = result.users[0];
            const userDoc = await this.get(user.uid);
            if (!userDoc)
                return defines_1.ERROR_USER_DOC_NOT_FOUND;
            return user;
        }
        catch (e) {
            return {
                code: "ERROR_USER_SEARCH",
                message: e.message,
            };
        }
    }
    // static async userSearch(data: { uid: string; name: string; phoneNumber: string }) {
    //   if (!(await this.isAdmin(data.uid))) {
    //     return {
    //       code: ERROR_YOU_ARE_NOT_ADMIN,
    //       message: "To manage user, you need to sign-in as an admin.",
    //     };
    //   }
    // }
    /**
     *
     * ! warning. this is very week password, but it is difficult to guess.
     * ! You may add more properties like `phone number`, `email` to make the password more strong.
     *
     * @deprecated Do not use this anymore.
     * @param doc user model
     * @returns password string
     */
    static generatePassword(doc) {
        return doc.id + "-" + doc.registeredAt;
    }
    /**
     * Generate and save new password under `/user-setting/<uid>/password` and return it.
     * @param uid the user's uid
     */
    static async generateNewPassword(uid) {
        const password = utils_1.Utils.uuid();
        await ref_1.Ref.userSettings(uid).set({ password: password });
        return password;
    }
    /**
     * Returns user profile data at `/users/<uid>` plus `/user-settings/<uid>/password`.
     * @param data data.id is the user uid.
     *
     */
    static async getSignInToken(data) {
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        const snapshot = await ref_1.Ref.signInTokenDoc(data.id).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            await ref_1.Ref.signInTokenDoc(data.id).remove();
            const user = await User.get(val.uid);
            if (user) {
                const password = await setting_1.Setting.value(user.id, "password");
                user.password = password;
            }
            return user;
        }
        throw defines_1.ERROR_SIGNIN_TOKEN_NOT_EXISTS;
    }
}
exports.User = User;
//# sourceMappingURL=user.js.map