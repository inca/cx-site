package ru.circumflex.site

import _root_.ru.circumflex.freemarker.FreemarkerHelper
import java.text.SimpleDateFormat
import java.util.Date
import ru.circumflex.core.{Circumflex, RequestRouter}
import ru.ciridiri.{Page, CiriDiri}
import ru.circumflex.md.Markdown
import org.apache.commons.io.IOUtils

class MainRouter extends RequestRouter
    with FreemarkerHelper {
  ctx += "host" -> header("Host")
  ctx += "currentYear" -> new SimpleDateFormat("yyyy").format(new Date)
  // read sitemap
  ctx += "sitemap" -> Page.findByUri("/sitemap")
  // let ciridiri handle the rest
  new CiriDiri()
  // now some rough stuff for Git
  get("/\\.git") = {
    val p = Runtime.getRuntime.exec(Array("git","status"))
    val in = p.getInputStream
    try {
      var status = new String(IOUtils.toCharArray(in))
          .replaceAll("(?:\\n|\\A)#", "\n")
          .replaceAll("\n(?! {4,})", "  \n")
      ctx += "status" -> Markdown(status)
    } finally {
      in.close
      p.waitFor
    }
    ftl("/git.ftl")
  }
  post("/\\.git") = {
    if (param("add") != None) {
      Runtime.getRuntime.exec(Array("git","add",".")).waitFor
    } else if (param("commit") != None) {
      val msg = param("message").get
      val p = Runtime.getRuntime.exec(Array("git","commit","-a","-m",msg))
      val out = p.getOutputStream
      try {
        out.write(msg.getBytes("utf-8"))
      } finally {
        out.close
      }
      p.waitFor
    } else if (param("push") != None) {
      Runtime.getRuntime.exec(Array("git","push","origin","master")).waitFor
    } else if (param("pull") != None) {
      Runtime.getRuntime.exec(Array("git","pull","origin","master")).waitFor
    }
    redirect("/.git")
  }

}