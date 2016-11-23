import React from 'react'
import ReactDOM from 'react-dom'
import {{ cookiecutter.package_slug }} from './{{ cookiecutter.package_slug }}.js'

// ReactDOM.render(<App />, document.getElementById('App');
ReactDOM.render(<{{ cookiecutter.package_slug }} />,document.getElementById("{{ cookiecutter.package_slug }}"))

var url = require("file-loader?name=index.html!../index.html")
