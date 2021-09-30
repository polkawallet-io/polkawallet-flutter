const fs = require('fs');
const path = require('path');
const webpack = require('webpack');

// absolute paths to all symlinked modules inside `nodeModulesPath`
// adapted from https://github.com/webpack/webpack/issues/811#issuecomment-405199263
const findLinkedModules = (nodeModulesPath) => {
  const modules = [];

  fs.readdirSync(nodeModulesPath).forEach(dirname => {
    const modulePath = path.resolve(nodeModulesPath, dirname);
    const stat = fs.lstatSync(modulePath);

    if (dirname.startsWith('.')) {
      // not a module or scope, ignore
    } else if (dirname.startsWith('@')) {
      // scoped modules
      modules.push(...findLinkedModules(modulePath));
    } else if (stat.isSymbolicLink()) {
      const realPath = fs.realpathSync(modulePath);
      const realModulePath = path.resolve(realPath, 'node_modules');

      modules.push(realModulePath);
    }
  });

  return modules;
};

const config = {
  entry: ['./src/index.js'],
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'main.js'
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'babel-loader',
        exclude: /node_modules/
      },
      {
        test: /\.mjs$/,
        include: /node_modules/,
        type: 'javascript/auto'
      }
    ]
  },
  mode: 'production',
  resolve: {
    // work with npm/yarn link
    // see https://github.com/webpack/webpack/issues/985
    // see https://github.com/vuejs-templates/webpack/pull/688
    symlinks: false,
    modules: [
      // provide absolute path to the main node_modules,
      // to avoid webpack searching around and getting confused
      // see https://webpack.js.org/configuration/resolve/#resolve-modules
      path.resolve('./node_modules'),
      // include linked node_modules as fallback, in case the deps haven't
      // yet propagated to the main node_modules
      ...findLinkedModules(path.resolve('./node_modules'))
    ],
    extensions: ['.ts', '.js', '.mjs', '.json', 'cjs'],
    fallback: {
      crypto: require.resolve('crypto-browserify'),
      stream: require.resolve('stream-browserify'),
      constants: require.resolve('constants-browserify')
    }
  },
  plugins: [
    // fix "process/buffer is not defined" error:
    new webpack.ProvidePlugin({
      process: ['process/browser.js'],
      Buffer: ['buffer', 'Buffer']
    }),
  ]
};

module.exports = config;
