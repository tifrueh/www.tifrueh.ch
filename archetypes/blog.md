+++
title = "{{ strings.Replace (strings.SliceString .File.ContentBaseName 16) "-" " " | title }}"
date = {{ .Date }}
description = ""
draft = true
url = "/blog/{{ time.Now.Format "2006/01" }}/{{ strings.SliceString .File.ContentBaseName 16 }}"
+++
