var grunt = require('grunt');

module.exports = function(grunt) {
    grunt.registerTask('default', 'default task description', function(){
      console.log('hello world');
    });

    grunt.initConfig({
        browserify: {
            options: {}
            files:[
                {src: ['index.js', 'js/*.js'] dest: 'js/bundle.js'}
            ]
        }
        watchify: {
            options: {}
            files:[
                {src: ['coffee/*', /*'coffee/*.coffee'*/] dest: 'js/bundle.js'}
            ]
        }
    })

    grunt.loadNpmTasks('grunt-browserify');
    grunt.loadNpmTasks('watchify');
