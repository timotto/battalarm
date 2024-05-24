const fs = require('fs')
const path = require('path')

const localeDirectory = './src/locales'
const referenceFilename = 'app_en.arb'

const main = () => {
  const files = fs.readdirSync(localeDirectory)
  const arbs = files.filter(filename => filename !== referenceFilename)
  const refArb = readArb(referenceFilename)
  const refKeys = translationKeysOf(refArb)

  const allOk = arbs
    .map(arb => compareArb(arb, refKeys))
    .filter(ok => !ok)
    .length === 0

  if (allOk) console.log('all translation keys present')
}

const compareArb = (arb, refKeys) => {
  const keys = translationKeysOf(readArb(arb))
  const missing = refKeys.filter(refKey => keys.indexOf(refKey) === -1)
  if (missing.length === 0) return true
  console.log(`missing keys in ${arb}:`)
  console.table(missing)
  return false
}

const translationKeysOf = (arb) => {
  return Object.keys(arb).filter(key => !key.startsWith('@'));
}

const readArb = (filename) => {
  return JSON.parse(fs.readFileSync(path.join(localeDirectory, filename)).toString())
}

main()
