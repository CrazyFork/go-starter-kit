
# Features

* 这个工程实现了 reactjs 在golang中的服务端渲染, 核心的逻辑就是引入了golang实现的js runtime, 在runtime的帮助下   js可以与golang进行交互,相互调用, 所以 src/react.go 的实现逻辑需要注意下
    * server 端渲染会调用 client js 中的 main 函数作为入口函数, 所以注意下 main 函数的定义
    * server 端会把 server render 的 data 注入到 window['--app-initial'] 这个变量, 通过 react.html template.
    * 前段组件的 onEnter 函数定义是作为组件数据请求用的, 所有的ajax 请求应该走这里, 然后dispatch 到 redux 的 store
        中。但是如果是server side render，数据会从html模板中注入, 所以 SSR 中的第一次 http 请求会被skip掉。 `client/router/routes` 有详细定义
        onEnter 会被 react-router 调用, v3 的版本, 不知道v4改怎么处理了。
    * `client/router/toString` 这个文件的函数会被 server 端调用, 用来 Server side rendering string, 然后将处理完的结果(golang/ja runtime)通过callback
        传递到golang那层.


    

* 这个工程的前段技术栈
    * js
        * react , redux , react-router
    * css
        * precss, postcss
    * 这个工程的前段项目通过webpack + express 的配置方式实现了前端的HMR, 和后端接口请求的proxy.
        css开启了css module, 用这种方式引入的样式.
        
        

    

* makefile 的写法可以好好学习下
* hot.proxy.js 用了 express 的 proxy middlewar, 将所有非静态资源的请求 proxy 到 golang 启动的server中

    
问题:
* 前段的 webpack 版本比较低
* golang 实现的js runtime 我怎么感觉用来执行 server-rendering 都有些担心
    * 只支持 es5 规范, 感觉过几年就应该不用了
    * 这个自定义的引擎的另外的一个问题就是怕好多标准的方法不支持

* 当前项目使用 go-bindata 将所有静态资源打包到最终的binary当中, 我总觉得不是很好的方式, 而且资源的 versioning 该怎么弄这又是一个核心的问题













# go-starter-kit [![wercker status](https://app.wercker.com/status/cd5a782c425b1feb06844dcc701e528c/s/master "wercker status")](https://app.wercker.com/project/bykey/cd5a782c425b1feb06844dcc701e528c) [![Join the chat at https://gitter.im/olebedev/go-starter-kit](https://img.shields.io/gitter/room/nwjs/nw.js.svg?maxAge=2592000&style=plastic)](https://gitter.im/olebedev/go-starter-kit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> This project contains a quick starter kit for **Facebook React** Single Page Apps with **Golang** server side render via goja javascript engine, implemented in pure Golang and also with a set of useful features for rapid development of efficient applications.

## What it contains?

* server side render via [goja](https://github.com/dop251/goja)
* api requests between your react application and server side application directly  via [fetch polyfill](https://github.com/olebedev/gojax/tree/master/fetch)
* title, Open Graph and other domain-specific meta tags render for each page at the server and at the client
* server side redirect
* embedding static files into artefact via bindata
* high performance [echo](https://github.com/labstack/echo) framework
* advanced cli via [cli](https://github.com/codegangsta/cli)
* Makefile based project
* one(!) terminal window process for development
* routing via [react-router](https://github.com/reactjs/react-router)
* ES6 & JSX via [babel-loader](https://github.com/babel/babel-loader) with minimal runtime dependency footprint
* [redux](https://rackt.org/redux/) as state container
* [redux-devtools](https://github.com/gaearon/redux-devtools)
* css styles without global namespace via PostCSS, [css-loader](https://github.com/webpack/css-loader) & css-modules
* separate css file to avoid FOUC
* hot reloading via [react-transform](https://github.com/gaearon/babel-plugin-react-transform) & [HMR](http://webpack.github.io/docs/hot-module-replacement.html)
* webpack bundle builder
* eslint and golint rules for Makefile

## Workflow dependencies

* [golang](https://golang.org/)
* [node.js](https://nodejs.org/) with [yarn](https://yarnpkg.com)
* [GNU make](https://www.gnu.org/software/make/)

Note that probably not works at windows.

## Project structure

##### The server's entry point
```
$ tree server
server
├── api.go
├── app.go
├── bindata.go <-- this file is gitignored, it will appear at compile time
├── conf.go
├── data
│   └── templates
│       └── react.html
├── main.go <-- main function declared here
├── react.go
└── utils.go
```

The `./server/` is flat golang package.

##### The client's entry point

It's simple React application

```
$ tree client
client
├── actions.js
├── components
│   ├── app
│   │   ├── favicon.ico
│   │   ├── index.js
│   │   └── styles.css
│   ├── homepage
│   │   ├── index.js
│   │   └── styles.css
│   ├── not-found
│   │   ├── index.js
│   │   └── styles.css
│   └── usage
│       ├── index.js
│       └── styles.css
├── css
│   ├── funcs.js
│   ├── global.css
│   ├── index.js
│   └── vars.js
├── index.js <-- main function declared here
├── reducers.js
├── router
│   ├── index.js
│   ├── routes.js
│   └── toString.js
└── store.js
```

The client app will be compiled into `server/data/static/build/`.  Then it will be embedded into go package via _go-bindata_. After that the package will be compiled into binary.

**Convention**: javascript app should declare [_main_](https://github.com/olebedev/go-starter-kit/blob/master/client/index.js#L4) function right in the global namespace. It will used to render the app at the server side.

## Install

Clone the repo:

```
$ git clone git@github.com:olebedev/go-starter-kit.git $GOPATH/src/github.com/<username>/<project>
$ cd $GOPATH/src/github.com/<username>/<project>
```

Install dependencies:

```
$ make install
```

## Run development

Start dev server:

```
$ make serve
```

that's it. Open [http://localhost:5001/](http://localhost:5001/)(if you use default port) at your browser. Now you ready to start coding your awesome project.

## Build

Install dependencies and type `NODE_ENV=production make build`. This rule is producing webpack build and regular golang build after that. Result you can find at `$GOPATH/bin`. Note that the binary will be named **as the current project directory**.

## License
MIT
