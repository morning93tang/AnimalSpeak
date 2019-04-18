package com.fit5120ta28.entity;

import java.io.Serializable;
//import java.text.DateFormat;
//import java.text.SimpleDateFormat;
//import java.util.Date;

public class TestEntity implements Serializable {
	private static final long serialVersionUID = 1L;
	private Long id;
	private String data;
	
	public TestEntity() {
		super();
	}
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getData() {
		return data;
	}
	public void setData(String data) {
		this.data = data;
	}
}
