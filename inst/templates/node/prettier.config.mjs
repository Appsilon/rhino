/** @type {import("prettier").Config} */
export default {
  overrides: [
    {
      files: "../app/js/**/*.js",
      options: {
        singleQuote: true,
      },
    },
  ],
};
