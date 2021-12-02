# Dev Remarks

This contains basic information for building the js module and may be obvious to the seasoned js-/web dev.

## Babel
Babel is responsible for code transpiling. It ensures that the generated code runs on
all targeted environments. 

`@babel/preset-env` replaces the legacy `@babel-preset-es2015`. The old one transpiled
the code generically to `es2015` aka `es5`. The new `@babel/preset-env` allows to be much
more specific. It specifically includes transformations and polyfills for the targeted environments
given in the `.browserslistrc` file (or in package.json).

The currently targeted browsers can be viewed with `yarn browserslist`.

As this package only runs in the native webViews of Android and IOS, most of the architectures are excluded
in the `.browerslistrc`.

## Webpack
Webpack is a module-bundler. It often runs babel as one of its jobs. However, its main task is to create a dependency
graph of all modules and files (also `.css` and images) and bundles that all together in a single file that is 
ready to be served to the browser. It ensures that the necessary polyfills are included and only compiles code
from the modules that is in fact imported somewhere - in other words, it builds the bare minimum of the code.

## Jest
To be able to run the tests from Webstorm, we must add the following line the to the run/debug config in the node 
options.

```
--experimental-vm-modules
```
