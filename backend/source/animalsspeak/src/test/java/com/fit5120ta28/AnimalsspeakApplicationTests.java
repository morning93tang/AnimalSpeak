package com.fit5120ta28;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import com.google.gson.Gson;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;


import java.io.*;
import java.util.ArrayList;
//import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.bind.DatatypeConverter;

import com.fit5120ta28.controller.FunctionController;
import com.fit5120ta28.mapper.FunctionMapper;
import com.fit5120ta28.util.*;

@RunWith(SpringRunner.class)
@SpringBootTest
public class AnimalsspeakApplicationTests {

	@Autowired
	FunctionMapper FunctionMapper;
	@Autowired
	FunctionController FunctionController;
	@Autowired
	SendEmail SendEmail;
	
	
	List<String> missList = new ArrayList<String>();
	List<String> missListRs = new ArrayList<String>();
	public static final String DEST = "reportPdf/hello_world.pdf";
	
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
		rs3.add("red kangaroo");
		
		rs2.put("animals",rs3);
		rs1.put("file", "1556358949813QyxtUM5j");
		rs1.put("ccAddress", "769991835@qq.com");
		
//		rs.put("lon", "145.863221");
//		rs1.put("lat", "-35.81");
//		rs1.put("lon", "142.89");
//		rs1.put("animal", "Australian Magpie");
//		rs= FunctionController.getAroundAnimalLocationByName(rs1);
//		rs1.put("userName", "TIANYI YUAN");
//		rs1.put("email", "769991835@qq.com");
//		rs1.put("msg", "lllllllll lll lllllll 1lll1 11lll1 1ll1 lll 1111 lll11ll1 11l 1llll11 11111 1 111111");
//		rs1.put("img","data:image/jpeg;base64,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");
		
		//Yellow-footed Antechinus
		//FunctionController.getRandomQuizOfSelectSound();
//		rs= FunctionController.sendEmailOfReport(rs1);
		//System.out.println(rs.get("response"));
		//SendEmail.send(rs.get("response"));
		//SendEmail.ccMail(rs.get("response"),"769991835@qq.com");
//		rs= FunctionController.generateReportPdf(rs1);
		
		//System.out.println(missList);
//		System.out.println("write0");
//		File file = new File(DEST);
//
//        file.getParentFile().mkdirs();
//
//        createPdf(DEST);
		//convertBase64toImg();
	}
	
	public void convertBase64toImg() {
		String base64String = "abc";
        String[] strings = base64String.split(",");
        String extension;
        switch (strings[0]) {//check image's extension
            case "data:image/jpeg;base64":
                extension = "jpeg";
                break;
            case "data:image/png;base64":
                extension = "png";
                break;
            default://should write cases for more images types
                extension = "jpg";
                break;
        }
        //convert base64 string to binary data
        byte[] data = DatatypeConverter.parseBase64Binary(strings[1]);
        String path = "injuried/test_image." + extension;
        File file = new File(path);
        try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file))) {
            outputStream.write(data);
            outputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        
	}
	
	public void createPdf(String dest) throws IOException {
		System.out.println("write1");
        //Initialize PDF writer
        PdfWriter writer = new PdfWriter(dest);
        //Initialize PDF document
        PdfDocument pdf = new PdfDocument(writer);
        // Initialize document
        Document document = new Document(pdf);
        //Add paragraph to the document
        document.add(new Paragraph("Hello World!"));
        //Close document
        
        document.close();

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
