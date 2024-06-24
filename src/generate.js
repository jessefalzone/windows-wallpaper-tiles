import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs/promises';
import Handlebars from 'handlebars';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const IMG_DIR = path.resolve(__dirname, '../public/images');
const TEMPLATE = path.resolve(__dirname, './template.hbs');
const OUTPUT_HTML = path.resolve(__dirname, '../public/index.html');
const CSS_FILE = path.resolve(__dirname, '../public/main.css');
const DEFAULT_CHECKED_VALUE = 'Windows31_Zigzag';

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
        default: validValue === DEFAULT_CHECKED_VALUE,
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

  await fs.writeFile(CSS_FILE, cssContent);
}

(async function main() {
  const files = await getAllFilesAndDirectories(IMG_DIR);

  const templateString = await fs.readFile(TEMPLATE);
  const template = Handlebars.compile(templateString.toString());
  const html = template({ files });

  await fs.writeFile(OUTPUT_HTML, html);
  await generateCSS(files);

  console.log(`HTML and CSS files generated: ${OUTPUT_HTML}, ${CSS_FILE}`);
})();
