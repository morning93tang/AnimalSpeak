package com.fit5120ta28;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fit5120ta28.controller.FunctionController;
import com.fit5120ta28.mapper.FunctionMapper;

@RunWith(SpringRunner.class)
@SpringBootTest
public class AnimalsspeakApplicationTests {

	@Autowired
	FunctionMapper FunctionMapper;
	
	@Test
	public void contextLoads() throws Exception {
		System.out.println("start!!!!!!");
		//csvTest1();
		test3();
	}
	
	public void test2(){
		Map<String,String> rs = new HashMap<String,String>();
		Gson gson = new Gson();
		String jsonArray = gson.toJson(FunctionMapper.getAllAnimalsName());
		rs.put("response", jsonArray);
		System.out.println(jsonArray);
	}
	public void test3() {
		Map<String,String> rs = new HashMap<String,String>();
		Gson gson = new Gson();
		String jsonArray = gson.toJson(FunctionMapper.getAnimalsNameByClass("birds"));
		rs.put("response", jsonArray);
		System.out.println(jsonArray);
		
	}
	
	public void csvTest1() throws Exception {
		List<Double[]> temp1 = new ArrayList<Double[]>();
		temp1 = getLocationArray("datasets/Koala.csv");
		//System.out.println(temp1.get(50)[0]);
		//System.out.println(temp1.get(50)[1]);
		System.out.println(temp1.size());
		List<Double[]> temp2 = new ArrayList<Double[]>();
		temp2 = getLocationArray("datasets/Red Kangroo.csv");
		System.out.println(temp2.size());  
		List<Double[]> temp3 = new ArrayList<Double[]>();
		temp3 = calculateOverLapPoints(temp1,temp2);
		System.out.println(temp3.size());
		System.out.println(temp3.get(133)[0]);
		System.out.println(temp3.get(133)[1]);
		
		Gson gson = new Gson();
		
		String jsonArray = gson.toJson(temp3);
		System.out.println(jsonArray);
	}
	
	
		
	public List<Double[]> getLocationArray(String file) {
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		
		int count = 0;
		try {
			InputStreamReader isr = new InputStreamReader(new FileInputStream(file));
			BufferedReader reader = new BufferedReader(isr);
		    String line = null;
		  
		    while((line=reader.readLine())!=null){
		       if(count<=1) {
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
		       rs.add(pointArr);
		       count++;
		      
		   }
		   
		   //System.out.println(count);
		   reader.close();
		 
		  } catch (Exception e) {
			  System.out.println(count);
		      e.printStackTrace();
		  }
		
		return rs;
	}
	
	
	public List<Double[]> calculateOverLapPoints(List<Double[]> sp1,List<Double[]> sp2){
		System.out.println("-----------------------------");
		System.out.println(sp1.size());
		System.out.println(sp2.size());
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		//System.out.println(sp1.size());
		//System.out.println(sp2.size());
		for(int i = 0; i < sp1.size(); i++) {
			//double avg = 0d;
			for(int j = 0; j < sp2.size(); j++) {
				double x = Math.pow((sp1.get(i)[0] - sp2.get(j)[0]),2);
				double y = Math.pow((sp1.get(i)[1] - sp2.get(j)[1]),2);
				double dis = Math.sqrt(x+y);
				//System.out.println(x);
				//System.out.println(y);
				//System.out.println(dis);
				//avg = avg+dis;
				if(dis<0.2) {
					pointArr = new Double[2];
					pointArr[0] = sp1.get(i)[0];
					pointArr[1] = sp1.get(i)[1];
					rs.add(pointArr);
					pointArr = new Double[2];
					pointArr[0] = sp2.get(j)[0];
					pointArr[1] = sp2.get(j)[1];
					rs.add(pointArr);
				}
			}
			//avg = avg/sp2.size();
			//System.out.println(avg);
		}
		return rs;
		
		
	}
}
