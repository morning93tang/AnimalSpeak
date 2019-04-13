package com.fit5120ta28.controller;

import java.io.IOException;
import java.util.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.apache.coyote.Response;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

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
	@Autowired  
    ResourceLoader loader;  
	
	/*Main API entrance
	 * 
	 * accept request and process it then send response back
	 * 
	 * 
	 * */
	@RequestMapping(value="/restapi/ios",method = RequestMethod.POST)
    @ResponseBody
    @CrossOrigin//(origins = "http://localhost:8080")
    public Map<String,String> function(@RequestBody String requestString,@RequestParam(name="methodId", required=true)int functionid,@RequestParam(name="postData", required=false)String other) throws Exception {
		System.out.println("requestString is:"+requestString);
		ObjectMapper mapper = new ObjectMapper(); 
		TypeReference<HashMap<String,String>> typeRef = new TypeReference<HashMap<String,String>>() {};
		TypeReference<HashMap<String,List<String>>> typeRefList = new TypeReference<HashMap<String,List<String>>>() {};
		Map<String,String> temp = new HashMap<String,String>();
		Map<String,List<String>> tempList = new HashMap<String,List<String>>();
		
		switch(functionid){
			case 1:
				temp = mapper.readValue(other, typeRef);
				return test1(temp);
			case 2:
				tempList = mapper.readValue(other, typeRefList);
				return filterSpeciLocation(tempList);
			case 3:
				//temp = mapper.readValue(other, typeRef);
				return getAllAnimalsName();
			case 4:
				temp = mapper.readValue(other, typeRef);
				return getAnimalsNameByClass(temp);
			case 5:
				temp = mapper.readValue(other, typeRef);
				return searchAnimalListByString(temp);
			case 6:
				temp = mapper.readValue(other, typeRef);
				return getAroundAnimalsByLatLon(temp);
			case 7:
				temp = mapper.readValue(other, typeRef);
				return getAroundAnimalLocationByName(temp);
			case 8:
				temp = mapper.readValue(other, typeRef);
				return getAnimalVoiceUrlByName(temp);
			default:
				return test2();
				
		
		}

		
    }
	
	public Map<String,String> test1(Map<String,String> data) {
		Map<String,String> rs = new HashMap<String,String>();
		TestEntity te = FunctionMapper.test1((long) 1);
		System.out.println("input:"+data.get("abc"));
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
	
	//calculate the distance between user location and around animals and filter them
	public Map<String,String> getAroundAnimalsByLatLon(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		double lat = Double.parseDouble(data.get("lat"));
		double lon = Double.parseDouble(data.get("lon"));
		rs = AnimalsSpeakLib.calculateAroundAnimals(lat,lon);
		System.out.println(rs);
		return rs;
	}
	
	//get certain animal location within a distance
	public Map<String,String> getAroundAnimalLocationByName(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		String animal = "datasets/"+data.get("animal")+".csv";
		double lat = Double.parseDouble(data.get("lat"));
		double lon = Double.parseDouble(data.get("lon"));
		Double[] dob = new Double[2];
		dob[0] = lat;
		dob[1] = lon;
		rs = AnimalsSpeakLib.getAroundAnimalLocationByName(animal,dob);
		System.out.println(rs);
		return rs;
	}
	
	////calculate the overlap area of two animals
	public Map<String,String> filterSpeciLocation(Map<String,List<String>> data) throws Exception{
		Map<String,String> rs = new HashMap<String,String>();
		List<Double[]> tempRs = new ArrayList<Double[]>();
		List<Double[]> result = new ArrayList<Double[]>();
		List<String> missList = new ArrayList<String>();
		//List<String> missListRs = new ArrayList<String>();
		System.out.println(data.get("animals"));
		List<String> animals = new ArrayList<String>(data.get("animals"));
		
		for(int i=0; i< animals.size();i++) {
			if(i==0) {
				tempRs = AnimalsSpeakLib.getLocationArray(AnimalsSpeakLib.formFileName(animals.get(0)));
				if(tempRs!=null) {
					result = tempRs;
				}else {
					System.out.println("pass null file");
					missList.add(animals.get(i));
					continue;
				}
				
				System.out.println("init done");
			}else {
				List<Double[]> follow = new ArrayList<Double[]>();
				tempRs = AnimalsSpeakLib.getLocationArray(AnimalsSpeakLib.formFileName(animals.get(i)));
				if(tempRs!=null) {
					follow = tempRs;
					
				}else {
					System.out.println("pass null file");
					missList.add(animals.get(i));
					continue;
				}
				if(result.size()==0) {
					result = tempRs;
				}else {
					result = AnimalsSpeakLib.calculateOverLapPoints(result,follow);
				}
				
				System.out.println("follow done");
			}
			System.out.println("results size:"+result.size());
			//result = deduplicate3(result);
		}
		
		Gson gson = new Gson();
		String jsonArray = gson.toJson(result);
		rs.put("response", jsonArray);
//		for(int z = 0;z<missList.size();z++) {
//			String[] str1 = missList.get(z).split("/");
//			String[] str2 = str1[1].split("\\.");
//			missListRs.add(str2[0]);
//		}
		jsonArray = gson.toJson(missList); 
		rs.put("miss", jsonArray);
		System.out.println(rs);
		return rs;
	}
	
	//return all animals name in the database
	public Map<String,String> getAllAnimalsName(){	
		Map<String,String> rs = new HashMap<String,String>();
		Gson gson = new Gson();
		String jsonArray = gson.toJson(FunctionMapper.getAllAnimalsName());
		rs.put("response", jsonArray);
		System.out.println(rs);
		return rs;
	}
	
	//return all animals name for a certain class
	public Map<String,String> getAnimalsNameByClass(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		Gson gson = new Gson();
		String jsonArray = gson.toJson(FunctionMapper.getAnimalsNameByClass(data.get("className")));
		rs.put("response", jsonArray);
		System.out.println(rs);
		return rs;
	}
	
	//search Animals Name via a query
	public Map<String,String> searchAnimalListByString(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		String str = "%"+data.get("query")+"%";
		Gson gson = new Gson();
		String jsonArray = gson.toJson(FunctionMapper.searchAnimalListByString(str));
		rs.put("response", jsonArray);
		System.out.println(rs);
		return rs;
	}
	
	public Map<String,String> getAnimalVoiceUrlByName(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		String ani = data.get("animal");
		String rsUrl = AnimalsSpeakLib.getAnimalVoiceUrlByName(ani);
		rs.put("response", rsUrl);
		System.out.println(rs);
		return rs;
	}
	
	//GET METHOD, get animal voice file from the server.
	// download file form server  
    @GetMapping("/getVoice")  
    public ResponseEntity<byte[]> getFile(@RequestParam("id") String id) throws IOException {  
        // specify file path  
    	String ani = id;
		//String rsUrl = AnimalsSpeakLib.getAnimalVoiceUrlByName(ani);
		
        String filePath = AnimalsSpeakLib.getAnimalVoiceUrlByName(ani);
        System.out.println(filePath);
        if(filePath.equalsIgnoreCase("null")) {
        	return null;
        }else {
        	byte[] body = IOUtils.toByteArray(loader.getResource("file:" + filePath).getInputStream());  
            String fileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length());  
            HttpHeaders headers=new HttpHeaders();  
            headers.add("Content-Disposition", "attachment;filename="+fileName);  
      
            return new ResponseEntity<byte[]>(body, headers, HttpStatus.OK);  
        }
        
    }  

}
