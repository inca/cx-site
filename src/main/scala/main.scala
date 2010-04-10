package ru.circumflex.site

import _root_.ru.circumflex.core.RequestRouter
import _root_.ru.circumflex.freemarker.FreemarkerHelper
import _root_.ru.ciridiri.CiriDiri

class MainRouter extends RequestRouter
    with FreemarkerHelper {
  new CiriDiri()
}