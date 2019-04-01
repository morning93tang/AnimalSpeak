package com.fit5120ta28;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

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
import java.util.List;

@RunWith(SpringRunner.class)
@SpringBootTest
public class AnimalsspeakApplicationTests {

	@Test
	public void contextLoads() throws Exception {
		System.out.println("start!!!!!!");
		csvTest1();
	}
	
	public void csvTest1() throws Exception {
		List<Double[]> temp1 = new ArrayList<>();
		temp1 = getLocationArray("datasets/Red Kangroo.csv");
		//System.out.println(temp1.get(50)[0]);
		//System.out.println(temp1.get(50)[1]);
		List<Double[]> temp2 = new ArrayList<>();
		temp2 = getLocationArray("datasets/Koala.csv");
		
		List<Double[]> temp3 = new ArrayList<>();
		temp3 = calculateOverLapPoints(temp1,temp2);
	}
	
	
		
	public List<Double[]> getLocationArray(String file) {
		List<Double[]> rs = new ArrayList<>();
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
		List<Double[]> rs = new ArrayList<>();
		for(int i = 0; i < sp1.size(); i++) {
			double avg = 0d;
			for(int j = 0; j < sp2.size(); j++) {
				double x = Math.pow((sp1.get(i)[0] - sp2.get(j)[0]),2);
				double y = Math.pow((sp1.get(i)[1] - sp2.get(j)[1]),2);
				double dis = Math.sqrt(x+y);
				avg = avg+dis;
			}
			avg = avg/sp2.size();
			System.out.println(avg);
		}
		return rs;
		
		
	}
}
