package com.fit5120ta28.lib;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class AnimalsSpeakLib {
	
	
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

	public String formFileName(String animal) {
		
		return "datasets/"+animal+".csv";
	}
	public String cookieGenerate(String usr,String pass)
	{
		return usr + pass + System.currentTimeMillis();
	}
	
	
	public List<Double[]> filterSpeciLocation() throws Exception {
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
	
		return temp3;
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
		  }
		
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
