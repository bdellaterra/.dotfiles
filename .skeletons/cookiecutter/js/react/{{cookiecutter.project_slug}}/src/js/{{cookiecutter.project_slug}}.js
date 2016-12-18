import React, { Component } from 'react'
import styles from '../css/{{ cookiecutter.project_slug }}.css'

class {{ cookiecutter.package_slug }} extends Component {
  render() {
    return <div>Hello from {{ cookiecutter.project_name }}!</div>;
  }
}

export default {{ cookiecutter.package_slug }}
