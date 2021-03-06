# Exports an object that defines
#  all of the configuration needed by the projects'
#  depended-on grunt tasks.
#
# You can find the parent object in: node_modules/lineman/config/application.coffee
#

module.exports = require(process.env['LINEMAN_MAIN']).config.extend "application",

  loadNpmTasks: ["grunt-markdown-blog"]

  markdown:
    options:
      author: "Roberto Guerra"
      title: "Stumbling On Code"
      description: "My clumsy self stumbling through a jungle of code."
      url: "http://www.mylinemanblog.com"
      rssCount: 10 #<-- remove, comment, or set to zero to disable RSS generation
      #disqus: "my_disqus_name" #<-- uncomment and set your disqus account name to enable disqus support
      layouts:
        wrapper: "app/templates/wrapper.us"
        index: "app/templates/index.us"
        post: "app/templates/post.us"
        page: "app/templates/page.us"
        archive: "app/templates/archive.us"
      paths:
        posts: "app/posts/*.md"
        pages: "app/pages/**/*.md"
        index: "index.html"
        archive: "archive.html"
        rss: "index.xml"

    dev:
      dest: "generated"
      context:
        js: "../js/app.js"
        css: "../css/app.css"

    dist:
      dest: "dist"
      context:
        js: "../js/app.js"
        css: "../css/app.css"

  copy:
    stylesheet:
      files:[
        expand: false
        flatten: false
        filter: 'isFile'
        src: ['vendor/css/semantic.css']
        dest: 'generated/css/semantic.css'
      ]
    fonts:
      files:[
        expand: true
        flatten: true
        filter: 'isFile'
        src: ['vendor/fonts/*']
        dest: 'generated/fonts/'
      ]

  # Use grunt-markdown-blog in lieu of Lineman's built-in pages task
  prependTasks:
    common: ["markdown:dev", "copy:fonts"]
    dist: "markdown:dist"
  removeTasks:
    common: "pages:dev"
    dist: "pages:dist"

  watch:
    markdown:
      files: ["app/posts/*.md", "app/pages/**/*.md", "app/templates/*.us"]
      tasks: ["markdown:dev"]

    pages:
      files: []
      tasks: []

