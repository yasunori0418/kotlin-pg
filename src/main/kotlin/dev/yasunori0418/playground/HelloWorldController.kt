package dev.yasunori0418.playground

import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.GetMapping

@RestController
class HelloWorldController {
    @GetMapping("/")
    fun helloWorld(): String {
        return "Hello World!!"
    }
}
