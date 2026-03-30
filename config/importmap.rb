# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "three", to: "https://ga.jspm.io/npm:three@0.183.2/build/three.module.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
