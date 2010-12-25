package ru.circumflex
package site

import core._, freemarker._, markeven._
import java.io._
import _root_.freemarker.cache._
import _root_.freemarker.template.{TemplateExceptionHandler, Configuration}
import java.text.SimpleDateFormat
import java.util.Date

class FreeMarkerConf extends Configuration {
  setObjectWrapper(new ScalaObjectWrapper())
  setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER)
  setDefaultEncoding("utf-8")
  setTemplateLoader(new FileTemplateLoader(new File("src/main/resources"), false))
  setSharedVariable("currentYear", new SimpleDateFormat("yyyy").format(new Date))
}

class MarkevenProc extends MarkevenProcessor {
  addMacro("ctx", cnt => ctx.get(cnt.toString).map(_.toString).getOrElse(""))
}