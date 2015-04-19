module.exports = function(grunt) {
  var harpDir = '../_harp';
  var wwwDir = '../_www';
  var rootDir = '../..'

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    bower_concat: {
      all: {
        dest: 'build/vendor.js',
        cssDest: 'build/vendor.css',
        dependencies: {
          'backbone': ['underscore', 'jquery'],
          'bootstrap': 'jquery'
        },
        bowerOptions: {
          relative: false
        }
      }
    },
    uglify: {
      vendor: {
        dest: '../_harp/js/vendor.min.js',
        src: 'build/vendor.js'
      }
    },
    cssmin: {
      vendor: {
        dest: '../_harp/css/vendor.min.css',
        src: 'build/vendor.css'
      }
    },
    concat: {
      app: {
        src: ['app/00application.js.coffee', 'app/*/*'],
        dest: '../_harp/js/application.js.coffee'
      }
    },
    watch: {
      app: {
        files: ['app/00application.js.coffee', 'app/*/*'],
        tasks: 'concat'
      }
    },
    exec: {
      harp_compile: 'harp compile ' + harpDir + ' ' + wwwDir
    },
    clean: {
      clean_root: [rootDir + '/*', '!' + rootDir + '/_*'],
      options: {
        force: true
      }
    },
    copy: {
      move_compiled: {
        expand: true,
        cwd: wwwDir,
        src: '**',
        dest: rootDir
      }
    },
  });

  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-bower-concat');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-exec');
  grunt.loadNpmTasks('grunt-contrib-clean');

  // Default task(s).
  grunt.registerTask('default', ['uglify']);
  grunt.registerTask('deploy', ['bower_concat', 'uglify', 'cssmin', 'concat', 'exec', 'clean', 'copy']);

};