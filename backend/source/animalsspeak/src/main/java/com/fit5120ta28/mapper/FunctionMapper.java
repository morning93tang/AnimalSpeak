package com.fit5120ta28.mapper;

import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Component;

import com.fit5120ta28.entity.AnimalEntity;
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
	
	@Select("select animalsId,name,class from animals left join animal_class on animals.classId=animal_class.classId;")
	@Results({
        @Result(property = "animalsId",  column = "animalsId"),
        @Result(property = "name", column = "name"),
        @Result(property = "classId", column = "classId"),
        @Result(property = "className", column = "class")
    })
	List<AnimalEntity> getAllAnimalsName();
	
	@Select("select animalsId,name,class from animals left join animal_class on animals.classId=animal_class.classId WHERE class=#{name};")
	@Results({
        @Result(property = "animalsId",  column = "animalsId"),
        @Result(property = "name", column = "name"),
        @Result(property = "classId", column = "classId"),
        @Result(property = "className", column = "class")
    })
	List<AnimalEntity> getAnimalsNameByClass(String name);
	
	@Select("select animalsId,name,class from animals left join animal_class on animals.classId=animal_class.classId WHERE name like #{query};")
	@Results({
        @Result(property = "animalsId",  column = "animalsId"),
        @Result(property = "name", column = "name"),
        @Result(property = "classId", column = "classId"),
        @Result(property = "className", column = "class")
    })
	List<AnimalEntity> searchAnimalListByString(String query);
	
}
