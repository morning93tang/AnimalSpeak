package com.fit5120ta28.controller;

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

import com.fit5120ta28.entity.*;
import com.fit5120ta28.mapper.*;
import com.fit5120ta28.lib.*;
import com.google.gson.Gson;


@Controller
public class FunctionController {

	public FunctionController() {}
	
	@Autowired
	FunctionMapper FunctionMapper;
	@Autowired
	AnimalsSpeakLib AnimalsSpeakLib;

	
	@RequestMapping(value="/restapi/ios",method = RequestMethod.POST)
    @ResponseBody
    @CrossOrigin//(origins = "http://localhost:8080")
    public Map<String,String> function(@RequestBody String requestString,@RequestParam(name="methodId", required=true)int functionid,@RequestParam(name="postData", required=true)String other) throws Exception {
		System.out.println("requestString is:"+requestString);
		ObjectMapper mapper = new ObjectMapper(); 
		TypeReference<HashMap<String,String>> typeRef = new TypeReference<HashMap<String,String>>() {};
		Map<String,String> temp = new HashMap<String,String>();
		
		
		switch(functionid){
			case 1:
				temp = mapper.readValue(other, typeRef);
				return test1(temp);
			case 2:
				temp = mapper.readValue(other, typeRef);
				return filterSpeciLocation();
			default:
				return test2();
				
		
		}

		
    }
	
	public Map<String,String> test1(Map<String,String> other) {
		Map<String,String> rs = new HashMap<String,String>();
		TestEntity te = FunctionMapper.test1((long) 1);
		System.out.println("input:"+other.get("abc"));
		if(te == null) {
			rs.put("response", "no such id");
			return rs;
		}else {
			rs.put("response", te.getData());
		}
		
		
		return rs;
	}
	
	
	public Map<String,String> test2() {
		Map<String,String> rs = new HashMap<String,String>();
		
		rs.put("response", "test ok3!");
		
		return rs;
	}
	
	
	public Map<String,String> filterSpeciLocation() throws Exception{
		Map<String,String> rs = new HashMap<String,String>();
		Gson gson = new Gson();
		String jsonArray = gson.toJson(AnimalsSpeakLib.filterSpeciLocation());
		rs.put("response", jsonArray);
		return rs;
	}
	
	public Map<String,String> getAllAnimalsName(){
		Map<String,String> rs = new HashMap<String,String>();
		return rs;
	}
	
	
}
