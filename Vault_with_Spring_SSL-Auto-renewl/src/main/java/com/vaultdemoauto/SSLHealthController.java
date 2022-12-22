package com.vaultdemoauto;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SSLHealthController {

	@GetMapping("/")
	public String health() {
		return "App Running";
	}
}
