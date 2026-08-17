/**
 * Pink Crystal — Windows 注入辅助（node 独立脚本，避免 cmd 内联引号问题）
 * 用法：node inject.js <main.css> <skin.css> [index.html]
 *  1) 幂等剥离旧皮肤块（前缀 WORKBUDDY_SKIN + lastIndexOf END SKIN）
 *  2) 将 skin.css 追加到主样式末尾
 *  3) 若提供 index.html，清理其中残留的 skin.css <link>
 */
const fs = require('fs');

function stripSkin(s) {
  const a = s.indexOf('/* WORKBUDDY_SKIN');
  const e = s.lastIndexOf('/* END SKIN */');
  if (a >= 0 && e > a) {
    s = s.slice(0, a) + s.slice(e + '/* END SKIN */'.length);
  }
  return s;
}

(function main() {
  const [, , mainCss, skinCss, idxHtml] = process.argv;
  if (!mainCss || !skinCss) {
    console.error('[inject.js] usage: node inject.js <main.css> <skin.css> [index.html]');
    process.exit(1);
  }

  let s = fs.readFileSync(mainCss, 'utf8');
  const had = s.indexOf('/* WORKBUDDY_SKIN') >= 0;
  if (had) {
    s = stripSkin(s);
    console.log('[inject.js] stripped previous skin block');
  }

  const skin = fs.readFileSync(skinCss, 'utf8');
  s = s + '\n' + skin;
  fs.writeFileSync(mainCss, s);

  if (idxHtml && fs.existsSync(idxHtml)) {
    let h = fs.readFileSync(idxHtml, 'utf8');
    if (/skin\.css/i.test(h)) {
      h = h.replace(/<link[^>]*skin\.css[^>]*>\s*/gi, '');
      fs.writeFileSync(idxHtml, h);
      console.log('[inject.js] cleaned stray skin.css <link> in index.html');
    }
  }

  if (!fs.readFileSync(mainCss, 'utf8').includes('/* WORKBUDDY_SKIN')) {
    console.error('[inject.js] FAIL: skin marker not found after inject');
    process.exit(1);
  }
  console.log('[inject.js] injected OK');
})();
