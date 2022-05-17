import * as functions from "firebase-functions";
import { User } from "../classes/user";
import { ready } from "../ready";

export const userCreate = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}")
    .onCreate((snapshot, context) => {
      return User.create(context.params.uid, {});
    });

export const signInToken = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res }, async (data) => {
        res.status(200).send(await User.getSignInToken(data));
      });
    });
