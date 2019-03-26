package com.animalsSpeak.backend.controller;
import java.io.IOException;
import java.util.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.apache.coyote.Response;
import org.springframework.beans.factory.annotation.Autowired;


import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.animalsSpeak.backend.entity.*;
import com.animalsSpeak.backend.lib.*;
import com.animalsSpeak.backend.mapper.*;
import com.animalsSpeak.backend.util.*;


@Controller
public class FunctionController {

	public FunctionController() {
		
	}
	
	@RequestMapping(value="/rpc/authorize",method = RequestMethod.POST)
    @ResponseBody
    @CrossOrigin//(origins = "http://localhost:8080")
    public Map<String,String> function(@RequestBody String requestString,@RequestParam(name="methodId", required=true)int functionid,@RequestParam(name="postData", required=true)String other) throws JsonMappingException, IOException {
		System.out.println("requestString is:"+requestString);
		ObjectMapper mapper = new ObjectMapper(); 
		TypeReference<HashMap<String,String>> typeRef = new TypeReference<HashMap<String,String>>() {};
		Map<String,String> temp = new HashMap<String,String>();
		
		
		switch(functionid){
			case 1://check login password
				temp = mapper.readValue(other, typeRef);
				return test();
			default:
				return nullFunction();

		}
		
    }
	
	public Map<String,String> test() {
		Map<String,String> rs = new HashMap<String,String>();
		rs.put("rs_code", "1");
		rs.put("int_response", "1");
		rs.put("string_response1", "abcdefg");
		rs.put("string_response2", "接口测试");
		return rs;
	}
	
	public Map<String,String> nullFunction() {
		Map<String,String> rs = new HashMap<String,String>();
		rs.put("rs_code", "0");
		rs.put("description", "methodId error");
		return rs;
	}
}
