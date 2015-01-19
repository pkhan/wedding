module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'src/<%= pkg.name %>.js',
        dest: 'build/<%= pkg.name %>.min.js'
      }
    },
    bower_concat: {
      all: {
        dest: 'build/vendor.js',
        cssDest: 'build/vendor.css',
        dependencies: {
          'backbone': ['lodash', 'jquery'],
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
        src: 'app/**',
        dest: '../_harp/js/application.js.coffee'
      }
    }
  });

  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-bower-concat');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');

  // Default task(s).
  grunt.registerTask('default', ['uglify']);
  grunt.registerTask('deploy', ['bower_concat', 'uglify', 'cssmin', 'concat']);

};