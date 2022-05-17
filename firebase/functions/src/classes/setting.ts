import { Ref } from "./ref";
// import * as admin from "firebase-admin";
// import { GetUsersResult } from "firebase-admin/lib/auth/base-auth";
// import { ErrorCodeMessage } from "../interfaces/common.interface";

export class Setting {
  static async value(uid: string, name: string): Promise<any> {
    const snapshot = await Ref.userSetting(uid, name).get();
    if (snapshot.exists()) {
      return snapshot.val();
    } else {
      return null;
    }
  }
}
