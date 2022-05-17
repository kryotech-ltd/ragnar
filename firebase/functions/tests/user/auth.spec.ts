import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { Utils } from "../../src/classes/utils";
import { ERROR_WRONG_PASSWORD } from "../../src/defines";

new FirebaseAppInitializer();

describe("User auth test", () => {
  it("Create a user with password2 and test auth", async () => {
    // Create a user
    const id = "uid-a-" + Utils.getTimestamp();
    await User.create(id, {
      firstName: "fn",
    });
    const user = await User.get(id);
    expect(user).to.be.an("object").to.have.property("id").equal(id);

    // Generate and save a new password at /user-settings/<uid>/password
    const password = await User.generateNewPassword(user!.id);
    console.log("password; ", password);

    // Authenticate it.
    const re = await User.authenticate({ uid: id, password2: password });
    expect(re === "").true;
    const wrong = await User.authenticate({ uid: id, password2: "worng-password" });
    expect(wrong === ERROR_WRONG_PASSWORD).true;
  });
});
