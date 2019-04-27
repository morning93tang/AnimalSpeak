package com.fit5120ta28.lib;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.stereotype.Service;

import com.google.gson.Gson;

@Service
public class AnimalsSpeakLib {
	
	private static double AROUNDDIS = 0.2d;
	private static double OVERLAPTHRESHOLD = 0.3d;
	
	//String to hash md5
	public String crypt(String str) {
		if (str == null || str.length() == 0) {
			throw new IllegalArgumentException("String to encrypt cannot be null or zero length");
		}
		StringBuffer hexString = new StringBuffer();
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			md.update(str.getBytes());
			byte[] hash = md.digest();
			for (int i = 0; i < hash.length; i++) {
				if ((0xff & hash[i]) < 0x10) {
					hexString.append("0" + Integer.toHexString((0xFF & hash[i])));
				} else {
					hexString.append(Integer.toHexString(0xFF & hash[i]));
				}
			}
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return hexString.toString();
	}

	//construct file name	
	public String formFileName(String animal) {
		return "datasets/"+animal+".csv";
	}
	
	//generate a template cookie
	public String cookieGenerate(String usr,String pass)
	{
		return usr + pass + System.currentTimeMillis();
	}
	
	
	//read csv file via IO 
	public List<Double[]> getLocationArray(String file) {
		File checkName=new File(file);
		if(!checkName.exists()) {
			//missList.add(file);
			System.out.println("cannot find file:"+file);
			return null;
		}else {
			System.out.println(file+" loaded!");
		}
		
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		
		int count = 0;
		try {
			//define the input stream
			InputStreamReader isr = new InputStreamReader(new FileInputStream(file));
			//define the reader
			BufferedReader reader = new BufferedReader(isr);
		    String line = null;
		  
		    //iterate the line in the csv file
		    while((line=reader.readLine())!=null){
		    	
		       //skip first two rows
		       if(count<=2) {
		    	   count++;
		    	   continue;
		       }
		       //split data via ,
		       String item[] = line.split(",");
		    
		       //check if it is the valid row
		       if(item.length!=2) {
		    	   continue;
		       }
		       pointArr = new Double[2];
		       
		       //reach the end, out of loop
			   if(item[0].equalsIgnoreCase("end")) {
				   break;
		       }
			   pointArr[0] = Double.parseDouble(item[0]);
		       pointArr[1] = Double.parseDouble(item[1]);
		       //System.out.println(item[0]);
		       rs.add(pointArr);
		       count++;
		      
		   }
		   
		   //close reader
		   reader.close();
		 
		  } catch (Exception e) {
			  System.out.println(count);
		      e.printStackTrace();
		  }
		
		return rs;
	}
	
	//get animal location array depends on a point
	public List<Double[]> getLocationArrayByDis(String file,double x,double y) {
		File checkName=new File(file);
		if(!checkName.exists()) {//check if the file exists
			//not exist
			System.out.println("cannot find file:"+file);
			return null;
		}else {
			//exist
			System.out.println(file+" loaded!");
		}
		
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		
		int count = 0;
		try {
			//read files
			InputStreamReader isr = new InputStreamReader(new FileInputStream(file));
			BufferedReader reader = new BufferedReader(isr);
		    String line = null;
		  
		    while((line=reader.readLine())!=null){
		       if(count<=2) {
		    	   count++;
		    	   continue;
		       }
		       String item[] = line.split(",");
		       //System.out.println(item.length);
		       if(item.length!=2) {
		    	   continue;
		       }
		       pointArr = new Double[2];

			   if(item[0].equalsIgnoreCase("end")) {
				   break;
		       }
			   pointArr[0] = Double.parseDouble(item[0]);
		       pointArr[1] = Double.parseDouble(item[1]);
		       //System.out.println(item[0]);
		       //calculate the distance and check if in the certain range.
		       if(calculateTwoPointsDis(x,y,pointArr[0],pointArr[1])<AROUNDDIS) {
		    	   rs.add(pointArr);
			       count++;
		       }
		       
		      
		   }
		   
		   //System.out.println(count);
		   reader.close();
		 
		  } catch (Exception e) {
			  System.out.println(count);
		      e.printStackTrace();
		  }
		
		return rs;
	}
	
	//the mathematical calculation about the overlap points
	public List<Double[]> calculateOverLapPoints(List<Double[]> sp1,List<Double[]> sp2){
		
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		List<Double> checkPool = new ArrayList<Double>();
	
		for(int i = 0; i < sp1.size(); i++) {
			
			for(int j = 0; j < sp2.size(); j++) {
				
				//calculate distance between two points
				double x = Math.pow((sp1.get(i)[0] - sp2.get(j)[0]),2);
				double y = Math.pow((sp1.get(i)[1] - sp2.get(j)[1]),2);
				double dis = Math.sqrt(x+y);
			
				if(dis<OVERLAPTHRESHOLD) {
					//filter the duplicated location points
					if(validCheckPool(sp1.get(i)[0],sp1.get(i)[1],checkPool)) {
						continue;
					}else {
						pointArr = new Double[2];
						pointArr[0] = sp1.get(i)[0];
						pointArr[1] = sp1.get(i)[1];
						checkPool.add(pointArr[0]);
						checkPool.add(pointArr[1]);
						rs.add(pointArr);
					}
					if(validCheckPool(sp2.get(j)[0],sp2.get(j)[1],checkPool)) {
						continue;
					}else {
						pointArr = new Double[2];
						pointArr[0] = sp2.get(j)[0];
						pointArr[1] = sp2.get(j)[1];
						checkPool.add(pointArr[0]);
						checkPool.add(pointArr[1]);
						rs.add(pointArr);
					}
					
				}
			}
			
		}
		return rs;
		
		
	}
	
	//iterate the pool to check if there is a duplicated location point.
	public boolean validCheckPool(double x,double y,List<Double> li) {
		for(int i = 0; i< li.size();i=i+2) {
			if(li.get(i)==x && li.get(i+1)==y) {
				//find duplicated
				return true;
			}
		}
		return false;
	}
	
	
	
	public Map<String,String> calculateAroundAnimals(double lat,double lon){
		Map<String,String> rs = new HashMap<String,String>();
		String path = "datasets/";
		List<String> fileNameList = getFiles(path);
		List<String> aroundList = new ArrayList<String>();
		//iterate all animals dataset to calcuate the distance between them and the user location
		for(int i = 0 ; i < fileNameList.size();i++) {
			File checkName=new File(path+fileNameList.get(i));
			int count = 0;
			Double[] pointArr;
			List<Double[]> pointList = new ArrayList<Double[]>();
			try {
				InputStreamReader isr = new InputStreamReader(new FileInputStream(checkName));
				BufferedReader reader = new BufferedReader(isr);
			    String line = null;
			  
			    while((line=reader.readLine())!=null){
			       if(count<=2) {
			    	   count++;
			    	   continue;
			       }
			       String item[] = line.split(",");
			       //System.out.println(item.length);
			       if(item.length!=2) {
			    	   continue;
			       }
			       pointArr = new Double[2];

				   if(item[0].equalsIgnoreCase("end")) {
					   break;
			       }
				   pointArr[0] = Double.parseDouble(item[0]);
			       pointArr[1] = Double.parseDouble(item[1]);
			       //System.out.println(item[0]);
			       pointList.add(pointArr);
			       count++;
			      
			   }
			   
			   //System.out.println(count);
			   reader.close();
			   for(int k=0;k<pointList.size();k++) {
				   //compare the distance between the animal location and user location
				   if(calculateTwoPointsDis(lat,lon,pointList.get(k)[0],pointList.get(k)[1])<AROUNDDIS) {
					   //if within the location, add the animal name string into aroundlist.
					   aroundList.add(fileNameList.get(i).split("\\.")[0]);
					   break;
				   }
			   }
			   
			   
			  } catch (Exception e) {
				  
			      e.printStackTrace();
			  }
			
		}
		
		
		
		System.out.println(aroundList);
		Gson gson = new Gson();
		String jsonArray = gson.toJson(aroundList); 
		rs.put("response", jsonArray);

		return rs;
	}
	
	//return the distance of two points
	private double calculateTwoPointsDis(double lat,double lon,double itlat,double itlon) {
		double x = Math.pow((lat - itlat),2);
		double y = Math.pow((lon - itlon),2);
		double dis = Math.sqrt(x+y);
		
		return dis;
	}
	
	//get all filesName via path
	private static List<String> getFiles(String path) {
		List<String> fileNameList = new ArrayList<String>();
		File file = new File(path);
		//list files in a dictionary
		File[] array = file.listFiles();
		for(int i = 0 ; i< array.length;i++) {
			if(array[i].isFile()) {
				//add filenames to a list
				fileNameList.add(array[i].getName());
			}else if(array[i].isDirectory()) {
				getFiles(array[i].getName());
			}
			
		}
		return fileNameList;
	}
	
	//get animal location by name
	public Map<String,String> getAroundAnimalLocationByName(String ani,Double[] p){
		Map<String,String> rs = new HashMap<String,String>();
		Gson gson = new Gson();
		String jsonArray = gson.toJson(getLocationArrayByDis(ani,p[0],p[1])); 
		rs.put("response", jsonArray);
		
		return rs;
	}
	
	
	//return animal voice url if it exists
	public String getAnimalVoiceUrlByName(String ani){
		String name = "AnimalSound/"+ani;
		
		File checkName_mp3=new File(name+".mp3");
		File checkName_wav=new File(name+".wav");
		//check if the mp3 file exist
		if(checkName_mp3.exists()) {
			return name+".mp3";
		}else {
			//check if the wav file exist
			if(checkName_wav.exists()) {
				return name+".wav";
			}else {
				return "null";
			}
		}

	}
	
	//return a random sound url for the quiz use
	public String getRandomSoundUrl(){
		//define sound files path
		String soundFolder = "AnimalSound/";
		
		//put all sound files into a list
		List<String> soundFileList = getFiles(soundFolder);
		
		//get a random int as index
		int index = getRandomIntFromRange(0,soundFileList.size()-1);
		
		//get Random sound file name
		String seedSound = soundFileList.get(index);
		String seedSoundPureName = seedSound.split("\\.")[0];
		System.out.println(seedSoundPureName);
		
		return seedSoundPureName;
		
	}
	
	//get a random integer from the range
	public int getRandomIntFromRange(int min,int max) {
		int randomNum = ThreadLocalRandom.current().nextInt(min, max + 1);
		return randomNum;
	}
	
	//generate Answer List used by the quiz
	public List<String> generateAnswerList(String answer) {
		String datasetPath = "datasets/";
		
		//put all dataset filename into a list
		List<String> fileList = getFiles(datasetPath);
		
		//a list that stores three options
		List<String> optionList = new ArrayList<String>();
		//add answer to the list
		optionList.add(answer);
		
		//get 3 options into the list , prevent duplicated answer
		while(optionList.size()!=4) {
			String candidateAnswer = fileList.get(getRandomIntFromRange(0,fileList.size()-1)).split("\\.")[0];
			if(!checkStringinList(candidateAnswer,optionList)) {
				optionList.add(candidateAnswer);
			}
		}
		//shuffle the answers in random order
		Collections.shuffle(optionList);
		//System.out.println(optionList);
		return optionList;
	}
	
	//check if the string already in a list
	private boolean checkStringinList(String target,List<String> pool){
		for(String str : pool) {
			if(str.equalsIgnoreCase(target)) {
				return true;
			}
		}
		return false;
	}
	
	
	
	
	
	
}
