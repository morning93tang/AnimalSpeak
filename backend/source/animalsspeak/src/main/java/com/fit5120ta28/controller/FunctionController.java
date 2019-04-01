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
import com.hoshiumi.mathumi.entity.InvitationRecordEntity;
import com.hoshiumi.mathumi.entity.MobileVertEntity;
import com.hoshiumi.mathumi.entity.UserEntity;
import com.hoshiumi.mathumi.util.BCrypt;

@Controller
public class FunctionController {

	public FunctionController() {}
	
	@Autowired
	FunctionMapper FunctionMapper;


	
	@RequestMapping(value="/restapi/ios",method = RequestMethod.POST)
    @ResponseBody
    @CrossOrigin//(origins = "http://localhost:8080")
    public Map<String,String> function(@RequestBody String requestString,@RequestParam(name="methodId", required=true)int functionid,@RequestParam(name="postData", required=true)String other) throws JsonMappingException, IOException {
		System.out.println("requestString is:"+requestString);
		ObjectMapper mapper = new ObjectMapper(); 
		TypeReference<HashMap<String,String>> typeRef = new TypeReference<HashMap<String,String>>() {};
		Map<String,String> temp = new HashMap<String,String>();
		
		
		switch(functionid){
			case 1:
				temp = mapper.readValue(other, typeRef);
				return test1(temp);
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
	
	
	public Map<String, String> signupNewUser(Map<String, String> signup) {
		Map<String,String> rs = new HashMap<String,String>();
						
		
		
		
		if(FunctionMapper.getOneByUsername(signup.get("username"))!=null) {
			rs.put("response_code", "4");
			rs.put("response_text", "duplicate username");
			return rs;
		}
		
	
		
		if(!me.getVert_code().equalsIgnoreCase(signup.get("vertification").trim())) {
			rs.put("response_code", "2");
			rs.put("response_text", "vertification code not correct");
			return rs;
		}
		
		String invitationEntityId = null;
		if(!signup.get("invitation").trim().equals("")) {
			invitationEntityId = AuthorizeMapper.getInvitationEntityIdByInvitationCode(signup.get("invitation").trim());
			if(invitationEntityId==null) {
				rs.put("response_code", "3");
				rs.put("response_text", "no such invitation code");
				return rs;
			}
			
		}
		
		
		//construct UserEntity instance
		UserEntity user = new UserEntity();
		user.setUsername(signup.get("username"));
		//Hash password
		String hashed = BCrypt.hashpw(signup.get("password"), BCrypt.gensalt());
		user.setPassword_salthash(hashed);
		user.setFirstname(signup.get("firstname").toUpperCase());
		user.setLastname(signup.get("lastname").toUpperCase());
		user.setPhone(signup.get("mobile"));
		
	
		
		
		//preview finish, start sql inserting.
		boolean updateFlag = AuthorizeMapper.createNewUserByForm(user);
		if(!updateFlag) {
			rs.put("response_code", "500");
			//user table insert failed
			rs.put("response_text", "db insert failed");
		}
		
		//construct InvitationRecord instance
		if(invitationEntityId!=null) {
			InvitationRecordEntity invitationRecord = new InvitationRecordEntity();
			invitationRecord.setInvitation_date(new Date());
			invitationRecord.setUserid(AuthorizeMapper.getOneByUsername(user.getUsername()).getUserid());
			invitationRecord.setInvitation_entityId(Long.parseLong(invitationEntityId));
			
			updateFlag = AuthorizeMapper.createInvitationRecord(invitationRecord);
		}
		
		if(!updateFlag) {
			rs.put("response_code", "501");
			//invitation_record table insert failed
			rs.put("response_text", "db insert failed");
		}else {
			rs.put("response_code", "200");
			rs.put("response_text", "ok");
		}
		
		
		
		return rs;
	}
	
	
	
}
