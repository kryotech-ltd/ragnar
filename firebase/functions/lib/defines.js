"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ERROR_EMPTY_COMMENT = exports.ERROR_EMPTY_INDUSTRY = exports.ERROR_EMPTY_EXPERIENCES = exports.ERROR_EMPTY_PROFICIENCY = exports.ERROR_WRONG_STATUS = exports.ERROR_FAILED_TO_CREATE_REPORT = exports.ERROR_WRONG_TARGET = exports.ERROR_ALREADY_REPORTED = exports.ERROR_EMPTY_REASON = exports.ERROR_EMPTY_TARGET_ID = exports.ERROR_EMPTY_TARGET = exports.ERROR_EMPTY_JOB_ACCOMODATION = exports.ERROR_EMPTY_JOB_BENEFIT = exports.ERROR_EMPTY_JOB_DUTY = exports.ERROR_EMPTY_JOB_REQUIREMENT = exports.ERROR_EMPTY_JOB_DESCRIPTION = exports.ERROR_EMPTY_JOB_NUMBER_OF_HIRING = exports.ERROR_EMPTY_JOB_SALARY = exports.ERROR_EMPTY_JOB_WORKING_HOURS = exports.ERROR_EMPTY_JOB_WORKING_DAYS = exports.ERROR_EMPTY_JOB_CATEGORY = exports.ERROR_EMPTY_COMPANY_ABOUT_US = exports.ERROR_EMPTY_COMPANY_EMAIL_ADDRESS = exports.ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER = exports.ERROR_EMPTY_COMPANY_MOBILE_NUMBER = exports.ERROR_LACK_OF_POINT = exports.ERROR_JOB_ALREADY_CREATED = exports.ERROR_EMPTY_COMPANY_DETAIL_ADDRESS = exports.ERROR_EMPTY_SGGNM = exports.ERROR_EMPTY_SINM = exports.ERROR_EMPTY_COMPANY_NAME = exports.ERROR_NOT_YOUR_JOB = exports.ERROR_JOB_NOT_EXIST = exports.ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY = exports.ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER = exports.ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY = exports.ERROR_EMPTY_TOKENS = exports.ERROR_EMPTY_TOPIC = exports.ERROR_EMPTY_UIDS = exports.ERROR_NOT_YOUR_COMMENT = exports.ERROR_COMMENT_NOT_EXISTS = exports.ERROR_ALREADY_DELETED = exports.ERROR_UPDATE_FAILED = exports.ERROR_YOU_ARE_NOT_ADMIN = exports.ERROR_NOT_YOUR_POST = exports.ERROR_POST_NOT_EXIST = exports.ERROR_USER_DOC_NOT_FOUND = exports.ERROR_USER_AUTH_NOT_FOUND = exports.ERROR_USER_NOT_FOUND = exports.ERROR_EMPTY_PASSWORD = exports.ERROR_WRONG_PASSWORD = exports.ERROR_LOGIN_FIRST = exports.ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE = exports.ERROR_NO_QUIZ_BY_THAT_ID = exports.ERROR_CATEGORY_NOT_EXISTS = exports.ERROR_EMPTY_CATEGORY = exports.ERROR_EMPTY_ID = exports.ERROR_EMPTY_UID = exports.ERROR_USER_EXISTS = exports.ERROR_TEST = void 0;
exports.ERROR_TEST = "ERROR_TEST";
exports.ERROR_USER_EXISTS = "ERROR_USER_EXISTS";
exports.ERROR_EMPTY_UID = "ERROR_EMPTY_UID";
exports.ERROR_EMPTY_ID = "ERROR_EMPTY_ID";
exports.ERROR_EMPTY_CATEGORY = "ERROR_EMPTY_CATEGORY";
exports.ERROR_CATEGORY_NOT_EXISTS = "ERROR_CATEGORY_NOT_EXISTS";
exports.ERROR_NO_QUIZ_BY_THAT_ID = "ERROR_NO_QUIZ_BY_THAT_ID";
exports.ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE = "ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE";
exports.ERROR_LOGIN_FIRST = "ERROR_LOGIN_FIRST";
exports.ERROR_WRONG_PASSWORD = "ERROR_WRONG_PASSWORD";
exports.ERROR_EMPTY_PASSWORD = "ERROR_EMPTY_PASSWORD";
exports.ERROR_USER_NOT_FOUND = "ERROR_USER_NOT_FOUND";
exports.ERROR_USER_AUTH_NOT_FOUND = "ERROR_USER_AUTH_NOT_FOUND";
exports.ERROR_USER_DOC_NOT_FOUND = "ERROR_USER_DOC_NOT_FOUND";
exports.ERROR_POST_NOT_EXIST = "ERROR_POST_NOT_EXIST";
exports.ERROR_NOT_YOUR_POST = "ERROR_NOT_YOUR_POST";
exports.ERROR_YOU_ARE_NOT_ADMIN = "ERROR_YOU_ARE_NOT_ADMIN";
// export const ERROR_CREATE_FAILED = "ERROR_CREATE_FAILED";
exports.ERROR_UPDATE_FAILED = "ERROR_UPDATE_FAILED";
exports.ERROR_ALREADY_DELETED = "ERROR_ALREADY_DELETED";
exports.ERROR_COMMENT_NOT_EXISTS = "ERROR_COMMENT_NOT_EXISTS";
exports.ERROR_NOT_YOUR_COMMENT = "ERROR_NOT_YOUR_COMMENT";
exports.ERROR_EMPTY_UIDS = "ERROR_EMPTY_UIDS";
exports.ERROR_EMPTY_TOPIC = "ERROR_EMPTY_TOPIC";
exports.ERROR_EMPTY_TOKENS = "ERROR_EMPTY_TOKENS";
exports.ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY = "ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY";
exports.ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER = "ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER";
exports.ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY = "ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY";
exports.ERROR_JOB_NOT_EXIST = "ERROR_JOB_NOT_EXIST";
exports.ERROR_NOT_YOUR_JOB = "ERROR_NOT_YOUR_JOB";
exports.ERROR_EMPTY_COMPANY_NAME = "ERROR_EMPTY_COMPANY_NAME";
// export const ERROR_EMPTY_PROVINCE = "ERROR_EMPTY_PROVINCE";
exports.ERROR_EMPTY_SINM = "ERROR_EMPTY_SINM";
exports.ERROR_EMPTY_SGGNM = "ERROR_EMPTY_SGGNM";
exports.ERROR_EMPTY_COMPANY_DETAIL_ADDRESS = "ERROR_EMPTY_COMPANY_DETAIL_ADDRESS";
exports.ERROR_JOB_ALREADY_CREATED = "ERROR_JOB_ALREADY_CREATED";
exports.ERROR_LACK_OF_POINT = "ERROR_LACK_OF_POINT";
exports.ERROR_EMPTY_COMPANY_MOBILE_NUMBER = "ERROR_EMPTY_COMPANY_MOBILE_NUMBER";
exports.ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER = "ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER";
exports.ERROR_EMPTY_COMPANY_EMAIL_ADDRESS = "ERROR_EMPTY_COMPANY_EMAIL_ADDRESS";
exports.ERROR_EMPTY_COMPANY_ABOUT_US = "ERROR_EMPTY_COMPANY_ABOUT_US";
exports.ERROR_EMPTY_JOB_CATEGORY = "ERROR_EMPTY_JOB_CATEGORY";
exports.ERROR_EMPTY_JOB_WORKING_DAYS = "ERROR_EMPTY_JOB_WORKING_DAYS";
exports.ERROR_EMPTY_JOB_WORKING_HOURS = "ERROR_EMPTY_JOB_WORKING_HOURS";
exports.ERROR_EMPTY_JOB_SALARY = "ERROR_EMPTY_JOB_SALARY";
exports.ERROR_EMPTY_JOB_NUMBER_OF_HIRING = "ERROR_EMPTY_JOB_NUMBER_OF_HIRING";
exports.ERROR_EMPTY_JOB_DESCRIPTION = "ERROR_EMPTY_JOB_DESCRIPTION";
exports.ERROR_EMPTY_JOB_REQUIREMENT = "ERROR_EMPTY_JOB_REQUIREMENT";
exports.ERROR_EMPTY_JOB_DUTY = "ERROR_EMPTY_JOB_DUTY";
exports.ERROR_EMPTY_JOB_BENEFIT = "ERROR_EMPTY_JOB_BENEFIT";
exports.ERROR_EMPTY_JOB_ACCOMODATION = "ERROR_EMPTY_JOB_ACCOMODATION";
exports.ERROR_EMPTY_TARGET = "ERROR_EMPTY_TARGET";
exports.ERROR_EMPTY_TARGET_ID = "ERROR_EMPTY_TARGET_ID";
exports.ERROR_EMPTY_REASON = "ERROR_EMPTY_REASON";
// export const ERROR_EMPTY_REPORTEE_UID = "ERROR_EMPTY_REPORTEE_UID";
exports.ERROR_ALREADY_REPORTED = "ERROR_ALREADY_REPORTED";
exports.ERROR_WRONG_TARGET = "ERROR_WRONG_TARGET";
exports.ERROR_FAILED_TO_CREATE_REPORT = "ERROR_FAILED_TO_CREATE_REPORT";
exports.ERROR_WRONG_STATUS = "ERROR_WRONG_STATUS";
exports.ERROR_EMPTY_PROFICIENCY = "ERROR_EMPTY_PROFICIENCY";
exports.ERROR_EMPTY_EXPERIENCES = "ERROR_EMPTY_EXPERIENCES";
exports.ERROR_EMPTY_INDUSTRY = "ERROR_EMPTY_INDUSTRY";
exports.ERROR_EMPTY_COMMENT = "ERROR_EMPTY_COMMENT";
//# sourceMappingURL=defines.js.map