import webpack from 'webpack'
import merge from 'webpack-merge'
import { resolve } from 'path'

import modules from './conf/webpack'

const baseConfig = {}

export default merge(baseConfig, modules)
