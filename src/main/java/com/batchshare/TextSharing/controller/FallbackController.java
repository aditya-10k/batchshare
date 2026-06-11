package com.batchshare.TextSharing.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FallbackController {

    @GetMapping("/{code:^(?!api|ws|urlshortner|createRoom|all-messages|expiry|mailer|health|index\\.html|favicon\\.png|.*\\.js|.*\\.css|.*\\.png|.*\\.json|.*\\.ico)[a-zA-Z0-9_-]+$}")
    public String forward() {
        return "forward:/index.html";
    }
}
