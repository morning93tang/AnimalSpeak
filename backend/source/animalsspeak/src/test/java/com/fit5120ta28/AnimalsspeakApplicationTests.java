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
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.fit5120ta28.controller.FunctionController;
import com.fit5120ta28.mapper.FunctionMapper;

@RunWith(SpringRunner.class)
@SpringBootTest
public class AnimalsspeakApplicationTests {

	@Autowired
	FunctionMapper FunctionMapper;
	@Autowired
	FunctionController FunctionController;
	
	List<String> missList = new ArrayList<String>();
	List<String> missListRs = new ArrayList<String>();
	
	@Test
	public void contextLoads() throws Exception {
		System.out.println("start!!!!!!");
		//deduplicate3();
		//csvTest1();
		//testsearchAnimalListByString();
		Map<String,String> rs = new HashMap<String,String>();
		Map<String,String> rs1 = new HashMap<String,String>();
		Map<String,List<String>> rs2 = new HashMap<String,List<String>>();
		List<String> rs3 = new ArrayList<String>();
		rs1.put("animal","australian Funnel-Web Spider");
		rs1.put("lat", "-37.57158726");
		rs1.put("lon", "149.8374922");
		rs= FunctionController.getAroundAnimalLocationByName(rs1);
		//rs= FunctionController.getAllAnimalsName();
		
		//System.out.println(missList);
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
	
	public void testsearchAnimalListByString() {
		Map<String,String> rs = new HashMap<String,String>();
		String str = "%kan%";
		Gson gson = new Gson();
		String jsonArray = gson.toJson(FunctionMapper.searchAnimalListByString(str));
		rs.put("response", jsonArray);
		System.out.println(jsonArray);
	}
	
	public void csvTest1() throws Exception {
		List<Double[]> result = new ArrayList<Double[]>();
		List<Double[]> tempRs = new ArrayList<Double[]>();
		//List<Double[]> temp1 = new ArrayList<Double[]>();
		List<String> animals = new ArrayList<String>();
		animals.add("koala");
		animals.add("red kangaroo");
		animals.add("dingo");
//		
//		animals.add("Galah");
//		animals.add("little penguin");
		
		for(int i=0; i< animals.size();i++) {
			if(i==0) {
				tempRs = getLocationArray(formFileName(animals.get(0)));
				if(tempRs!=null) {
					result = tempRs;
				}else {
					System.out.println("pass null file");
					continue;
				}
				
				System.out.println("init done");
			}else {
				List<Double[]> follow = new ArrayList<Double[]>();
				tempRs = getLocationArray(formFileName(animals.get(i)));
				if(tempRs!=null) {
					follow = tempRs;
					
				}else {
					System.out.println("pass null file");
					continue;
				}
				if(result.size()==0) {
					result = tempRs;
				}else {
					result = calculateOverLapPoints(result,follow);
				}
				
				System.out.println("follow done");
			}
			System.out.println("results size:"+result.size());
			//result = deduplicate3(result);
		}
		
		//temp1 = getLocationArray("datasets/Koala.csv");
		//System.out.println(temp1.get(50)[0]);
		//System.out.println(temp1.get(50)[1]);
		//System.out.println(temp1.size());
		//List<Double[]> temp2 = new ArrayList<Double[]>();
		//temp2 = getLocationArray("datasets/Red Kangroo.csv");
		//System.out.println(temp2.size());  
		//List<Double[]> temp3 = new ArrayList<Double[]>();
		//temp3 = calculateOverLapPoints(temp1,temp2);
		System.out.println(result.size());
		
		
		Gson gson = new Gson();
		
		String jsonArray = gson.toJson(result);
		System.out.println(jsonArray);
		for(int z = 0;z<missList.size();z++) {
			String[] str1 = missList.get(z).split("/");
			String[] str2 = str1[1].split("\\.");
			missListRs.add(str2[0]);
		}
		System.out.println(missListRs);
	}
	
	public String formFileName(String animal) {
		
		return "datasets/"+animal+".csv";
	}
	
	public List<Double[]> deduplicate(List<Double[]> li) {
		List<Double[]> result = new ArrayList<Double[]>();
		
		for(int i = 0 ; i < li.size();i++) {
			//System.out.println("i size:"+li.size()+"__"+"outer loop:"+i);
			if(i==0) {
				//System.out.println(li.get(0)[0]);
				result.add(li.get(0));
			}else {
				boolean f = true;
				for(int k = 0; k < result.size();k++) {
					if(checkDoubleArrEqual(result.get(k),li.get(i))) {
						f=false;
						break;
					}
				}
				if(f) {
					result.add(li.get(i));
				}
				
			}
			
		}
		return result;
	}
	
	public List<Double[]> deduplicate2(List<Double[]> li) {
		
		System.out.println("Before:"+li.size());
		Set<Double[]> set = new HashSet<Double[]>(li);
		List<Double[]> rs= new ArrayList<Double[]>(set);
		System.out.println("After:"+rs.size());
		return rs;
	}
	public List<Double[]> deduplicate3(List<Double[]> li) {
		List<String> nli = new ArrayList<String>();
		for(int i = 0;i<li.size();i++) {
			nli.add(combineDoubleAsString(li.get(i)));
		}
	
		System.out.println("Before:"+li.size());
		Set<String> set = new HashSet<String>(nli);
		List<String> rs= new ArrayList<String>(set);
		System.out.println("After:"+rs.size());
		List<Double[]> r2 = new ArrayList<Double[]>();
		for(int k=0; k < rs.size();k++) {
			
			String[] str = rs.get(k).split("\\|");
			//System.out.println(str.length);
			Double[] d = new Double[2];
			//System.out.println(str[0].indexOf("$"));
			
				d[0] = Double.valueOf(str[0]);
			
			
			d[1] = Double.valueOf(str[1]);
			r2.add(d);
		}
		return r2;
	}
	
	public String combineDoubleAsString(Double[] d) {
		String str1 = Double.toString(d[0]);
		String str2 = Double.toString(d[1]);
		return str1+"|"+str2;
	}
	
	public boolean checkDoubleArrEqual(Double[] d1,Double[] d2) {
		if(d1[0]==d2[0]&&d1[1]==d2[1]) {
			return true;
		}else {
			return false;
		}
	
	}
	
	
	public List<Double[]> getLocationArray(String file) {
		File checkName=new File(file);
		if(!checkName.exists()) {
			missList.add(file);
			System.out.println("cannot find file:"+file);
			return null;
		}else {
			System.out.println(file+" loaded!");
		}
			
		
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		
		int count = 0;
		try {
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
		       rs.add(pointArr);
		       count++;
		      
		   }
		   
		   //System.out.println(count);
		   reader.close();
		 
		  } catch (Exception e) {
			  System.out.println(count);
		      e.printStackTrace();
		      //missList.add(file);
		      //System.out.println("cannot find file:"+file);
		      //return null;
		  }
		System.out.println("load csv done");
		return rs;
	}
	
	
	public List<Double[]> calculateOverLapPoints(List<Double[]> sp1,List<Double[]> sp2){
		System.out.println("-----------------------------");
		System.out.println(sp1.size());
		System.out.println(sp2.size());
		List<Double[]> rs = new ArrayList<Double[]>();
		Double[] pointArr;
		List<Double> checkPool = new ArrayList<Double>();
		//System.out.println(sp1.size());
		//System.out.println(sp2.size());
		for(int i = 0; i < sp1.size(); i++) {
			//double avg = 0d;
			//System.out.println("outer:"+i);
			for(int j = 0; j < sp2.size(); j++) {
				//System.out.println("inner:"+j);
				double x = Math.pow((sp1.get(i)[0] - sp2.get(j)[0]),2);
				double y = Math.pow((sp1.get(i)[1] - sp2.get(j)[1]),2);
				double dis = Math.sqrt(x+y);
				//System.out.println(x);
				//System.out.println(y);
				//System.out.println(dis);
				//avg = avg+dis;
				if(dis<0.5) {
					
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
			//avg = avg/sp2.size();
			//System.out.println(avg);
		}
		return rs;
		
		
	}
	
	public boolean validCheckPool(double x,double y,List<Double> li) {
		for(int i = 0; i< li.size();i=i+2) {
			if(li.get(i)==x && li.get(i+1)==y) {
				return true;
			}
		}
		return false;
	}
}
