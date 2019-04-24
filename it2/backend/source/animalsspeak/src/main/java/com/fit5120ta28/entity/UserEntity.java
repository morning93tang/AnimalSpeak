package com.fit5120ta28.entity;

import java.io.Serializable;

public class UserEntity implements Serializable {

	private static final long serialVersionUID = 1L;
	private Long userid;
	private String username;
	private String password_salthash;
	private String firstname;
	private String lastname;
    
	public UserEntity() {
		super();
	}

	public Long getUserid() {
		return userid;
	}

	public void setUserid(Long userid) {
		this.userid = userid;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword_salthash() {
		return password_salthash;
	}

	public void setPassword_salthash(String password_salthash) {
		this.password_salthash = password_salthash;
	}

	public String getFirstname() {
		return firstname;
	}

	public void setFirstname(String firstname) {
		this.firstname = firstname;
	}

    public String getLastname() {
		return lastname;
	}

	public void setLastname(String lastname) {
		this.lastname = lastname;
	}

    
	@Override
	public String toString() {
	
		return "userName " + this.username + ", pasword " + this.password_salthash ;
	}

}
