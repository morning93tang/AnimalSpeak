package com.fit5120ta28.controller;

//import java.io.FileNotFoundException;
//import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.fit5120ta28.entity.*;
import com.fit5120ta28.mapper.*;
import com.fit5120ta28.lib.*;
import com.fit5120ta28.util.*;
import com.google.gson.Gson;
//import com.itextpdf.html2pdf.ConverterProperties;
//import com.itextpdf.html2pdf.HtmlConverter;
//import com.itextpdf.io.source.ByteArrayOutputStream;
//import com.itextpdf.kernel.font.PdfFont;
//import com.itextpdf.kernel.font.PdfFontFactory;
//import com.itextpdf.layout.font.FontProvider;

/*
 * This class receive the API request
 * 
 * */
@Controller
public class FunctionController {

	public FunctionController() {}
	
	@Autowired
	FunctionMapper FunctionMapper;
	@Autowired
	AnimalsSpeakLib AnimalsSpeakLib;
	@Autowired  
    ResourceLoader loader;  
	@Autowired
	SendEmail SendEmail;
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
		//put the parameter input into the map
		ObjectMapper mapper = new ObjectMapper(); 
		TypeReference<HashMap<String,String>> typeRef = new TypeReference<HashMap<String,String>>() {};
		TypeReference<HashMap<String,List<String>>> typeRefList = new TypeReference<HashMap<String,List<String>>>() {};
		Map<String,String> temp = new HashMap<String,String>();
		Map<String,List<String>> tempList = new HashMap<String,List<String>>();
		
		//distribute the function by the methodId
		switch(functionid){
			case 1:
				temp = mapper.readValue(other, typeRef);
				return test1(temp);
			case 2:
				tempList = mapper.readValue(other, typeRefList);
				return filterSpeciLocation(tempList);
			case 3:
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
				return getRandomQuizOfSelectSound();
			case 9:
				temp = mapper.readValue(other, typeRef);
				return generateReportPdf(temp);
			case 10:
				temp = mapper.readValue(other, typeRef);
				return sendEmailOfReport(temp);
			
			default:
				return test2();
				
		
		}

		
    }
	
	//test use function
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
	
	//test use function
	public Map<String,String> test2() {
		Map<String,String> rs = new HashMap<String,String>();
		
		rs.put("response", "test ok3!");
		
		return rs;
	}
	
	//calculate the distance between user location and around animals and filter them
	public Map<String,String> getAroundAnimalsByLatLon(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		
		//define lat and long
		double lat = Double.parseDouble(data.get("lat"));
		double lon = Double.parseDouble(data.get("lon"));
		
		//invoke calculation function
		rs = AnimalsSpeakLib.calculateAroundAnimals(lat,lon);
//		System.out.println(rs);
		return rs;
	}
	
	//get certain animal location within a distance
	public Map<String,String> getAroundAnimalLocationByName(Map<String,String> data) throws JsonParseException, JsonMappingException, IOException{
		Map<String,String> rs = new HashMap<String,String>();
		
		//form the file path string
		String animal = "datasets/"+data.get("animal")+".csv";
		
		//define lat and long
		double lat = Double.parseDouble(data.get("lat"));
		double lon = Double.parseDouble(data.get("lon"));
		Double[] dob = new Double[2];
		dob[0] = lat;
		dob[1] = lon;
		
		//invoke function to get certain around animals
		rs = AnimalsSpeakLib.getAroundAnimalLocationByName(animal,dob);
//		System.out.println(rs);
		return rs;
	}
	
	//calculate the overlap area of two animals
	public Map<String,String> filterSpeciLocation(Map<String,List<String>> data) throws Exception{
		Map<String,String> rs = new HashMap<String,String>();
		List<Double[]> tempRs = new ArrayList<Double[]>();
		List<Double[]> result = new ArrayList<Double[]>();
		List<String> missList = new ArrayList<String>();
		//List<String> missListRs = new ArrayList<String>();
//		System.out.println(data.get("animals"));
		//get animals list from the input
		List<String> animals = new ArrayList<String>(data.get("animals"));
		
		//iterate animals list
		for(int i=0; i< animals.size();i++) {
			//if it is the first file, do not merge, just use it.
			if(i==0) {
				//read csv file from IO stream
				tempRs = AnimalsSpeakLib.getLocationArray(AnimalsSpeakLib.formFileName(animals.get(0)));
				//check if the response is null
				if(tempRs!=null) {//not null
					result = tempRs;
				}else {//null
					System.out.println("pass null file");
					missList.add(animals.get(i));
					continue;
				}
				
				System.out.println("init done");
			}else {//merge the following animal habitats into the previous locations

				List<Double[]> follow = new ArrayList<Double[]>();
				//read csv file from IO stream
				tempRs = AnimalsSpeakLib.getLocationArray(AnimalsSpeakLib.formFileName(animals.get(i)));
				if(tempRs!=null) {
					follow = tempRs;
				}else {
					System.out.println("pass null file");
					//put unfound animals into a list
					missList.add(animals.get(i));
					continue;
				}
				if(result.size()==0) {
					//put this one directly into the result in case the first animal name in the iteration does not exist
					result = tempRs;
				}else {
					//calculate overlapping
					result = AnimalsSpeakLib.calculateOverLapPoints(result,follow);
				}
				
				System.out.println("follow done");
			}
			System.out.println("results size:"+result.size());
			//result = deduplicate3(result);
		}
		
		Gson gson = new Gson();
		//construct response into JSON 
		String jsonArray = gson.toJson(result);
		rs.put("response", jsonArray);
		jsonArray = gson.toJson(missList); 
		rs.put("miss", jsonArray);
//		System.out.println(rs);
		return rs;
	}
	
	//return all animals name in the database
	public Map<String,String> getAllAnimalsName(){	
		Map<String,String> rs = new HashMap<String,String>();
		//construct response into JSON 
		Gson gson = new Gson();
		
		//invoke the function that get all animals name
		String jsonArray = gson.toJson(FunctionMapper.getAllAnimalsName());
		rs.put("response", jsonArray);
//		System.out.println(rs);
		return rs;
	}
	
	//return all animals name for a certain class
	public Map<String,String> getAnimalsNameByClass(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		//construct response into JSON 
		Gson gson = new Gson();
		//invoke the function that get all animals name in a certain class
		String jsonArray = gson.toJson(FunctionMapper.getAnimalsNameByClass(data.get("className")));
		rs.put("response", jsonArray);
//		System.out.println(rs);
		return rs;
	}
	
	//search Animals Name via a query
	public Map<String,String> searchAnimalListByString(Map<String,String> data){
		Map<String,String> rs = new HashMap<String,String>();
		//form the query will be used in the SQL
		String str = "%"+data.get("query")+"%";
		//construct response into JSON 
		Gson gson = new Gson();
		//invoke the function that will search the query
		String jsonArray = gson.toJson(FunctionMapper.searchAnimalListByString(str));
		rs.put("response", jsonArray);
//		System.out.println(rs);
		return rs;
	}
	
	//return the quiz information,quiz type:choose sound
	public Map<String,String> getRandomQuizOfSelectSound()
	{
		Map<String,String> rs = new HashMap<String,String>();
		//generate an animal sound name(id) as the correct answer
		String getAnswerSoundId = AnimalsSpeakLib.getRandomSoundUrl();
		
		//generate a three-option answer list
		List<String> answerList = AnimalsSpeakLib.generateAnswerList(getAnswerSoundId);
		
		//construct response into JSON 
		Gson gson = new Gson();
		String jsonArray = gson.toJson(answerList);
		rs.put("response", jsonArray);
		rs.put("answer", getAnswerSoundId);
//		System.out.println(rs);
		return rs;
		
	}
	
	
	//GET METHOD, get animal voice file from the server.
	// download file form server  
    @GetMapping("/getVoice")  
    public ResponseEntity<byte[]> getFile(@RequestParam("id") String id) throws IOException {  
        // specify file path  
    	String ani = id;
    	// get the filePath
        String filePath = AnimalsSpeakLib.getAnimalVoiceUrlByName(ani);
//        System.out.println(filePath);
        if(filePath.equalsIgnoreCase("null")) {//no found file
        	return null;
        }else {//found file
        	//construct response 
        	byte[] body = IOUtils.toByteArray(loader.getResource("file:" + filePath).getInputStream());  
            String fileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length());  
            HttpHeaders headers=new HttpHeaders();
            headers.add("Content-Disposition", "attachment;filename="+fileName);  
            return new ResponseEntity<byte[]>(body, headers, HttpStatus.OK);  
        }
        
    }  
    
    /*
     * accept report information and use them to generate a pdf report
     * */
    public Map<String,String> generateReportPdf(Map<String,String> data) throws IOException{
    	Map<String,String> rs = new HashMap<String,String>();
    	//define pdf file name
    	String fileName = AnimalsSpeakLib.generatePdfTemplate(data);
    	String randomStr = AnimalsSpeakLib.getRandom6Int();
    	rs.put("response", fileName);
    	rs.put("verification_code", randomStr);
    	String codeStatus = String.valueOf(SendEmail.sendCode(data.get("email"),randomStr));
    	rs.put("verification_send_status", codeStatus);
    	System.out.println(rs);
		return rs;
    
    }
    
  
    
    //send Email to both government rescue dept. and to the reporter
    public Map<String,String> sendEmailOfReport(Map<String,String> data) throws IOException{
    	Map<String,String> rs = new HashMap<String,String>();
    	String pdfName = data.get("file");
    	String ccEmailAddress = data.get("ccAddress");
    	int mainSend = SendEmail.send(pdfName);
    	int ccSend = SendEmail.ccMail(pdfName,ccEmailAddress);
    	
    	rs.put("response", "government status:"+mainSend+"|cc status:"+ccSend);
//    	System.out.println(rs);
		return data;
    
    }
    
    @GetMapping("/getReport")  
    public ResponseEntity<byte[]> getReport(@RequestParam("id") String id) throws IOException {  
    
    	// get the filePath
        String filePath = "reportPdf/"+id+".pdf";
//        System.out.println(filePath);
        if(filePath.equalsIgnoreCase("null")) {//no found file
        	return null;
        }else {//found file
        	//construct response 
        	byte[] body = IOUtils.toByteArray(loader.getResource("file:" + filePath).getInputStream());  
            String fileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length());  
            HttpHeaders headers=new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/pdf"));
            //headers.add("Content-Disposition", "attachment;filename="+fileName);  
            headers.add("content-disposition", "inline;filename=" + fileName);
            return new ResponseEntity<byte[]>(body, headers, HttpStatus.OK);  
        }
        
    }  
}
