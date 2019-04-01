package com.fit5120ta28.mapper;

import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Date;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Component;

import com.fit5120ta28.entity.TestEntity;
import com.fit5120ta28.entity.UserEntity;

@Component
public interface FunctionMapper {
	
	@Select("SELECT * FROM test_table WHERE id = #{id}")
    @Results({
        @Result(property = "id",  column = "id"),
        @Result(property = "data", column = "data")
    })
	TestEntity test1(Long id);
	
	@Select("SELECT * FROM user WHERE username = #{username}")
    @Results({
        @Result(property = "userid",  column = "userid"),
        @Result(property = "username", column = "username"),
        @Result(property = "password_salthash", column = "password_salthash"),
        @Result(property = "firstname", column = "firstname"),
        @Result(property = "lastname", column = "lastname"),
        @Result(property = "phone", column = "phone"),
        @Result(property = "address", column = "address"),
        @Result(property = "logincookie", column = "logincookie")
    })
    UserEntity getOneByUsername(String username);
}
