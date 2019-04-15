package com.fit5120ta28.entity;

import java.io.Serializable;

public class AnimalEntity implements Serializable{

	private static final long serialVersionUID = 1L;
	private Long animalsId;
	private String name;
	private Long classId;
	private String className;
	private String facts;
	
	public AnimalEntity(){
		super();
	}


	public Long getAnimalsId() {
		return animalsId;
	}


	public void setAnimalsId(Long animalsId) {
		this.animalsId = animalsId;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	public Long getClassId() {
		return classId;
	}


	public void setClassId(Long classId) {
		this.classId = classId;
	}


	public String getClassName() {
		return className;
	}


	public void setClassName(String className) {
		this.className = className;
	}


	public String getFacts() {
		return facts;
	}


	public void setFacts(String facts) {
		this.facts = facts;
	}
	
	
}
