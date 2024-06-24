import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs/promises';
import Handlebars from 'handlebars';
import { minify } from 'html-minifier-terser';
import CleanCSS from 'clean-css';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const IMG_DIR = path.resolve(__dirname, '../public/images');
const TEMPLATE = path.resolve(__dirname, './template.hbs');
const OUTPUT_HTML = path.resolve(__dirname, '../public/index.html');
const OUTPUT_BACKGROUND_CSS = path.resolve(
  __dirname,
  '../public/backgrounds.css'
);
const OUTPUT_MAIN_CSS = path.resolve(__dirname, '../public/main.css');
const INPUT_MAIN_CSS = path.resolve(__dirname, './main.css');
const DEFAULT_CHECKED_VALUE = 'none';

async function getAllFilesAndDirectories(dirPath) {
  let results = [];

  const files = await fs.readdir(dirPath);

  for (let file of files) {
    let filePath = path.join(dirPath, file);
    const fileInfo = await fs.stat(filePath);

    if (fileInfo.isDirectory()) {
      const subdirectoryContents = await getAllFilesAndDirectories(filePath);
      results.push({
        name: file,
        contents: subdirectoryContents,
      });
    } else {
      if (!file.toLowerCase().endsWith('.png')) {
        continue;
      }

      let fileNameWithoutExt = path.basename(file, path.extname(file));
      let subdirName = path.basename(path.dirname(filePath));
      let relativeFilePath = `./images/${subdirName}/${file}`
        .replace(/\\/g, '\\\\')
        .replace(/'/g, "\\'");
      let validValue = `${subdirName}_${fileNameWithoutExt}`.replace(/\W/g, '');

      results.push({
        name: fileNameWithoutExt.replace(/\\/g, ''),
        path: relativeFilePath,
        value: validValue,
      });
    }
  }

  return results;
}

async function generateCSS(files) {
  let cssContent = '';

  for (let file of files) {
    for (let content of file.contents) {
      cssContent += `
        body:has(select option[value="${content.value}"]:checked) {
          background-image: url("${content.path}");
        }
      `;
    }
  }
  const options = {
    level: 2,
  };
  cssContent = new CleanCSS(options).minify(cssContent).styles;
  await fs.writeFile(OUTPUT_BACKGROUND_CSS, cssContent);

  const mainCss = await fs.readFile(INPUT_MAIN_CSS);
  await fs.writeFile(
    OUTPUT_MAIN_CSS,
    new CleanCSS(options).minify(mainCss).styles
  );
}

(async function main() {
  const files = await getAllFilesAndDirectories(IMG_DIR);

  const templateString = await fs.readFile(TEMPLATE);
  const template = Handlebars.compile(templateString.toString());
  const html = await minify(template({ files }), {
    minifyJS: true,
    collapseWhitespace: true,
    removeComments: true,
  });

  await fs.writeFile(OUTPUT_HTML, html);
  await generateCSS(files);

  console.log('Done!');
})();
