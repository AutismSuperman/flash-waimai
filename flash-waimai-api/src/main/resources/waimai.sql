/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MariaDB
 Source Server Version : 100407
 Source Host           : 127.0.0.1:3306
 Source Schema         : waimai

 Target Server Type    : MariaDB
 Target Server Version : 100407
 File Encoding         : 65001

 Date: 05/05/2023 15:52:19
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for t_cms_article
-- ----------------------------
DROP TABLE IF EXISTS `t_cms_article`;
CREATE TABLE `t_cms_article`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `author` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '作者',
  `content` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '内容',
  `id_channel` bigint(20) NOT NULL COMMENT '栏目id',
  `img` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '文章题图ID',
  `title` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标题',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '文章' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_cms_article
-- ----------------------------
INSERT INTO `t_cms_article` VALUES (1, 1, '2019-03-09 16:24:58', 1, '2019-05-10 13:22:49', 'enilu', '<div id=\"articleContent\" class=\"content\">\n<div class=\"ad-wrap\">\n<p style=\"margin: 0 0 10px 0;\">一般我们都有这样的需求：我需要知道库中的数据是由谁创建，什么时候创建，最后一次修改时间是什么时候，最后一次修改人是谁。flash-waimai最新代码已经实现该需求，具体实现方式网上有很多资料，这里做会搬运工，将flash-waimai的实现步骤罗列如下：%%</p>\n</div>\n<p>在Spring jpa中可以通过在实体bean的属性或者方法上添加以下注解来实现上述需求@CreatedDate、@CreatedBy、@LastModifiedDate、@LastModifiedBy。</p>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>@CreatedDate 表示该字段为创建时间时间字段，在这个实体被insert的时候，会设置值</p>\n</li>\n<li>\n<p>@CreatedBy 表示该字段为创建人，在这个实体被insert的时候，会设置值</p>\n</li>\n<li>\n<p>@LastModifiedDate 最后修改时间 实体被update的时候会设置</p>\n</li>\n<li>\n<p>@LastModifiedBy 最后修改人 实体被update的时候会设置</p>\n</li>\n</ul>\n<h2>使用方式</h2>\n<h3>实体类添加注解</h3>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>首先在实体中对应的字段加上上述4个注解</p>\n</li>\n<li>\n<p>在flash-waimai中我们提取了一个基础实体类BaseEntity，并将对应的字段添加上述4个注解,所有需要记录维护信息的表对应的实体都集成该类</p>\n</li>\n</ul>\n<pre>import&nbsp;org.springframework.data.annotation.CreatedBy;\nimport&nbsp;org.springframework.data.annotation.CreatedDate;\nimport&nbsp;org.springframework.data.annotation.LastModifiedBy;\nimport&nbsp;org.springframework.data.annotation.LastModifiedDate;\nimport&nbsp;javax.persistence.Column;\nimport&nbsp;javax.persistence.GeneratedValue;\nimport&nbsp;javax.persistence.Id;\nimport&nbsp;javax.persistence.MappedSuperclass;\nimport&nbsp;java.io.Serializable;\nimport&nbsp;java.util.Date;\n@MappedSuperclass\n@Data\npublic&nbsp;abstract&nbsp;class&nbsp;BaseEntity&nbsp;implements&nbsp;Serializable&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;@Id\n&nbsp;&nbsp;&nbsp;&nbsp;@GeneratedValue\n&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;Long&nbsp;id;\n&nbsp;&nbsp;&nbsp;&nbsp;@CreatedDate\n&nbsp;&nbsp;&nbsp;&nbsp;@Column(name&nbsp;=&nbsp;\"create_time\",columnDefinition=\"DATETIME&nbsp;COMMENT&nbsp;\'创建时间/注册时间\'\")\n&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;Date&nbsp;createTime;\n&nbsp;&nbsp;&nbsp;&nbsp;@Column(name&nbsp;=&nbsp;\"create_by\",columnDefinition=\"bigint&nbsp;COMMENT&nbsp;\'创建人\'\")\n&nbsp;&nbsp;&nbsp;&nbsp;@CreatedBy\n&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;Long&nbsp;createBy;\n&nbsp;&nbsp;&nbsp;&nbsp;@LastModifiedDate\n&nbsp;&nbsp;&nbsp;&nbsp;@Column(name&nbsp;=&nbsp;\"modify_time\",columnDefinition=\"DATETIME&nbsp;COMMENT&nbsp;\'最后更新时间\'\")\n&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;Date&nbsp;modifyTime;\n&nbsp;&nbsp;&nbsp;&nbsp;@LastModifiedBy\n&nbsp;&nbsp;&nbsp;&nbsp;@Column(name&nbsp;=&nbsp;\"modify_by\",columnDefinition=\"bigint&nbsp;COMMENT&nbsp;\'最后更新人\'\")\n&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;Long&nbsp;modifyBy;\n}</pre>\n<h3>实现AuditorAware接口返回操作人员的id</h3>\n<p>配置完上述4个注解后，在jpa.save方法被调用的时候，时间字段会自动设置并插入数据库，但是CreatedBy和LastModifiedBy并没有赋值 这两个信息需要实现AuditorAware接口来返回操作人员的id</p>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>首先需要在项目启动类添加@EnableJpaAuditing 注解来启用审计功能</p>\n</li>\n</ul>\n<pre>@SpringBootApplication\n@EnableJpaAuditing\npublic&nbsp;class&nbsp;AdminApplication&nbsp;extends&nbsp;WebMvcConfigurerAdapter&nbsp;{\n&nbsp;//省略\n}</pre>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>然后实现AuditorAware接口返回操作人员的id</p>\n</li>\n</ul>\n<pre>@Configuration\npublic&nbsp;class&nbsp;UserIDAuditorConfig&nbsp;implements&nbsp;AuditorAware&lt;Long&gt;&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;@Override\n&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;Long&nbsp;getCurrentAuditor()&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ShiroUser&nbsp;shiroUser&nbsp;=&nbsp;ShiroKit.getUser();\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if(shiroUser!=null){\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;shiroUser.getId();\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;null;\n&nbsp;&nbsp;&nbsp;&nbsp;}\n}</pre>\n</div>', 1, '1', 'flash-waimai 将所有表增加维护人员和维护时间信息');
INSERT INTO `t_cms_article` VALUES (2, 1, '2019-03-09 16:24:58', 1, '2019-03-23 23:12:16', 'enilu.cn', '<div id=\"articleContent\" class=\"content\">\n<div class=\"ad-wrap\">\n<p style=\"margin: 0 0 10px 0;\"><a style=\"color: #a00; font-weight: bold;\" href=\"https://my.oschina.net/u/3985214/blog/3018099?tdsourcetag=s_pcqq_aiomsg\" target=\"_blank\" rel=\"noopener\" data-traceid=\"news_detail_above_text_link_1\" data-tracepid=\"news_detail_above_text_link\">开发十年，就只剩下这套架构体系了！ &gt;&gt;&gt;</a>&nbsp;&nbsp;<img style=\"max-height: 32px; max-width: 32px;\" src=\"https://www.oschina.net/img/hot3.png\" align=\"\" /></p>\n</div>\n<h3>国际化</h3>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>flash-vue-admin实现国际化了，</p>\n</li>\n<li>\n<p>不了解上面两个的区别的同学可以再回顾下这个<a href=\"http://www.enilu.cn/flash-waimai/base/flash-vue-admin.html\">文档</a></p>\n</li>\n<li>\n<p>flash-vue-admin实现国际化的方式参考vue-element-admin的&nbsp;<a href=\"https://panjiachen.github.io/vue-element-admin-site/zh/guide/advanced/i18n.html\" target=\"_blank\" rel=\"noopener\">官方文档</a>,这里不再赘述,强烈建议你先把文档读了之后再看下面的内容。</p>\n</li>\n</ul>\n<h3>默认约定</h3>\n<p>针对网站资源进行国际园涉及到的国际化资源的管理维护，这里给出一些flash-vue-admin的资源分类建议，当然，你也可以根据你的实际情况进行调整。</p>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>src/lang/为国际化资源目录,目前提供了英文（en.js）和中文(zh.js)的两种语言实现。</p>\n</li>\n<li>\n<p>目前资源语言资源文件中是json配置主要有以下几个节点：</p>\n</li>\n<ul class=\" list-paddingleft-2\" style=\"list-style-type: square;\">\n<li>\n<p>route 左侧菜单资源</p>\n</li>\n<li>\n<p>navbar 顶部导航栏资源</p>\n</li>\n<li>\n<p>button 公共的按钮资源，比如：添加、删除、修改、确定、取消之类等等</p>\n</li>\n<li>\n<p>common 其他公共的资源，比如一些弹出框标题、提示信息、label等等</p>\n</li>\n<li>\n<p>login 登录页面资源</p>\n</li>\n<li>\n<p>config 参数管理界面资源</p>\n</li>\n</ul>\n<li>\n<p>目前针对具体的页面资源只做了登录和参数管理两个页面，其他具体业务界面仅针对公共的按钮做了国际化，你可以参考config页面资源进行配置进行进一步配置：/src/views/cfg/</p>\n</li>\n<li>\n<p>如果你有其他资源在上面对应的节点添加即可，针对每个页面特有的资源以页面名称作为几点进行维护，这样方便记忆和维护，不容易出错。</p>\n</li>\n</ul>\n<h3>添加新的语言支持</h3>\n<p>如果英文和中文两种语言不够，那么你可以通过下面步骤添加语言支持</p>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>在src/lang/目录下新增对应的资源文件</p>\n</li>\n<li>\n<p>在src/lang/index.js中import对应的资源文件</p>\n</li>\n<li>\n<p>在src/lang/index.js中的messages变量中加入新的语言声明</p>\n</li>\n<li>\n<p>在src/components/LangSelect/index.vue的语言下拉框中增加新的语言选项</p>\n</li>\n</ul>\n<h3>演示地址</h3>\n<ul class=\" list-paddingleft-2\">\n<li>\n<p>vue版本后台管理&nbsp;<a href=\"http://106.75.35.53:8082/vue/#/login\" target=\"_blank\" rel=\"noopener\">http://106.75.35.53:8082/vue/#/login</a></p>\n</li>\n<li>CMS内容管理系统的h5前端demo:<a href=\"http://106.75.35.53:8082/mobile/#/index\" target=\"_blank\" rel=\"noopener\">http://106.75.35.53:8082/mobile/#/index</a></li>\n</ul>\n</div>', 1, '2', 'web-flash1.0.1 发布，增加国际化和定时任务管理功能');
INSERT INTO `t_cms_article` VALUES (3, 1, '2019-03-09 16:24:58', 1, '2019-04-28 17:39:52', 'enilu.cn', '<div class=\"content\" id=\"articleContent\">\r\n                        <div class=\"ad-wrap\">\r\n                                                    <p style=\"margin:0 0 10px 0;\"><a data-traceid=\"news_detail_above_text_link_1\" data-tracepid=\"news_detail_above_text_link\" style=\"color:#A00;font-weight:bold;\" href=\"https://my.oschina.net/u/3985214/blog/3018099?tdsourcetag=s_pcqq_aiomsg\" target=\"_blank\">开发十年，就只剩下这套架构体系了！ &gt;&gt;&gt;</a>&nbsp;&nbsp;<img src=\"https://www.oschina.net/img/hot3.png\" align=\"\" style=\"max-height: 32px; max-width: 32px;\"></p>\r\n                                    </div>\r\n                        <p>flash-waimai使用的Spring Boot从1.5.1升级到2.1.1</p><p>下面为升级过程</p><ul class=\" list-paddingleft-2\"><li><p>版本升级</p><pre>&lt;spring.boot.version&gt;2.1.1.RELEASE&lt;/spring.boot.version&gt;\r\n&lt;springframework.version&gt;5.1.3.RELEASE&lt;springframework.version&gt;</pre></li><li><p>配置增加</p><pre>spring.main.allow-bean-definition-overriding=true\r\nspring.jpa.hibernate.use-new-id-generator-mappings=false</pre></li></ul><ul class=\" list-paddingleft-2\"><li><p>审计功能调整，调整后代码:</p><pre>@Configuration\r\npublic&nbsp;class&nbsp;UserIDAuditorConfig&nbsp;implements&nbsp;AuditorAware&lt;Long&gt;&nbsp;{\r\n&nbsp;&nbsp;&nbsp;&nbsp;@Override\r\n&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;Optional&lt;Long&gt;&nbsp;getCurrentAuditor()&nbsp;{\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ShiroUser&nbsp;shiroUser&nbsp;=&nbsp;ShiroKit.getUser();\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if(shiroUser!=null){\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;Optional.of(shiroUser.getId());\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;null;\r\n&nbsp;&nbsp;&nbsp;&nbsp;}\r\n}</pre></li><li><p>repository调整</p></li><ul class=\" list-paddingleft-2\" style=\"list-style-type: square;\"><li><p>之前的 delete(Long id)方法没有了，替换为：deleteById(Long id)</p></li><li><p>之前的 T findOne(Long id)方法没有了，替换为：		</p><pre>Optional&lt;T&gt;&nbsp;optional&nbsp;=&nbsp;***Repository.findById(id);\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(optional.isPresent())&nbsp;{\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;optional.get();\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;null;</pre></li></ul><li><p>随着这次Spring Boot的升级也顺便做了一些其他内容的调整和重构</p></li><ul class=\" list-paddingleft-2\" style=\"list-style-type: square;\"><li><p>springframework也从4.3.5.RELEASE升级到5.1.3.RELEASE</p></li><li><p>为减小复杂度service去掉接口和实现类的结构，基础功能的service直接使用实现类；当然具体业务中如果有需求你也可以这没用</p></li><li><p>去掉了一些暂时用不到的maven依赖</p></li><li><p>完善了基础功能的审计功能(之前有介绍审计功能的实现翻番，后续会专门发一篇文档来说明审计功能在系统总的具体用法，当然聪明的你看代码就知道了)</p></li></ul></ul>\r\n                    </div>', 1, '1', 'flash-waimai 升级 Spring Boot 到 2.1.1 版本');
INSERT INTO `t_cms_article` VALUES (4, 1, '2019-03-09 16:24:58', 1, '2019-04-28 00:34:21', 'enilu.cn', 'H5通用官网系统', 2, '17', 'H5通用官网系统');
INSERT INTO `t_cms_article` VALUES (5, 1, '2019-03-09 16:24:58', 1, '2019-04-28 00:34:36', 'enilu.cn', 'H5通用论坛系统', 2, '18', 'H5通用论坛系统');
INSERT INTO `t_cms_article` VALUES (6, 1, '2019-03-09 16:24:58', 1, '2019-04-28 00:38:33', 'enilu.cn', '官网建设方案', 3, '19', '官网建设方案');
INSERT INTO `t_cms_article` VALUES (7, 1, '2019-03-09 16:24:58', 1, '2019-04-28 00:39:48', 'enilu.cn', '论坛建设方案', 3, '22', '论坛建设方案');
INSERT INTO `t_cms_article` VALUES (8, 1, '2019-03-09 16:24:58', 1, '2019-04-28 17:39:52', 'enilu.cn', '案例1', 4, '3', '案例1');
INSERT INTO `t_cms_article` VALUES (9, 1, '2019-03-09 16:24:58', 1, '2019-04-28 00:39:11', 'enilu.cn', '案例2', 4, '20', '案例2');
INSERT INTO `t_cms_article` VALUES (14, 1, '2019-03-09 16:24:58', 1, '2019-04-28 00:39:25', 'test5', '<p>aaaaa<img class=\"wscnph\" src=\"http://127.0.0.1:8082/file/download?idFile=12\" /></p>', 4, '21', 'IDEA的代码生成插件发布啦');
INSERT INTO `t_cms_article` VALUES (15, 1, '2019-04-28 17:39:52', 1, '2019-05-05 15:36:57', 'enilu', '<p><img class=\"wscnph\" src=\"http://127.0.0.1:8082/file/download?idFile=24\" /></p>', 1, '25', '程序员头冷');

-- ----------------------------
-- Table structure for t_cms_banner
-- ----------------------------
DROP TABLE IF EXISTS `t_cms_banner`;
CREATE TABLE `t_cms_banner`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `id_file` bigint(20) NULL DEFAULT NULL COMMENT 'banner图id',
  `title` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标题',
  `type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '类型',
  `url` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '点击banner跳转到url',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '文章' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_cms_banner
-- ----------------------------
INSERT INTO `t_cms_banner` VALUES (1, 1, '2019-03-09 16:29:03', NULL, NULL, 1, '不打开链接', 'index', 'javascript:');
INSERT INTO `t_cms_banner` VALUES (2, 1, '2019-03-09 16:29:03', NULL, NULL, 2, '打打开站内链接', 'index', '/contact');
INSERT INTO `t_cms_banner` VALUES (3, 1, '2019-03-09 16:29:03', NULL, NULL, 6, '打开外部链接', 'index', 'http://www.baidu.com');
INSERT INTO `t_cms_banner` VALUES (4, 1, '2019-03-09 16:29:03', NULL, NULL, 1, '不打开链接', 'product', 'javascript:');
INSERT INTO `t_cms_banner` VALUES (5, 1, '2019-03-09 16:29:03', NULL, NULL, 2, '打打开站内链接', 'product', '/contact');
INSERT INTO `t_cms_banner` VALUES (6, 1, '2019-03-09 16:29:03', NULL, NULL, 6, '打开外部链接', 'product', 'http://www.baidu.com');
INSERT INTO `t_cms_banner` VALUES (7, 1, '2019-03-09 16:29:03', NULL, NULL, 1, '不打开链接', 'solution', 'javascript:');
INSERT INTO `t_cms_banner` VALUES (8, 1, '2019-03-09 16:29:03', NULL, NULL, 2, '打打开站内链接', 'solution', '/contact');
INSERT INTO `t_cms_banner` VALUES (9, 1, '2019-03-09 16:29:03', NULL, NULL, 6, '打开外部链接', 'solution', 'http://www.baidu.com');
INSERT INTO `t_cms_banner` VALUES (10, 1, '2019-03-09 16:29:03', NULL, NULL, 1, '不打开链接', 'case', 'javascript:');
INSERT INTO `t_cms_banner` VALUES (11, 1, '2019-03-09 16:29:03', NULL, NULL, 2, '打打开站内链接', 'case', '/contact');
INSERT INTO `t_cms_banner` VALUES (12, 1, '2019-03-09 16:29:03', NULL, NULL, 6, '打开外部链接', 'case', 'http://www.baidu.com');
INSERT INTO `t_cms_banner` VALUES (14, 1, '2019-03-09 16:29:03', NULL, NULL, 1, '不打开链接', 'news', 'javascript:');
INSERT INTO `t_cms_banner` VALUES (15, 1, '2019-03-09 16:29:03', NULL, NULL, 2, '打打开站内链接', 'news', '/contact');
INSERT INTO `t_cms_banner` VALUES (16, 1, '2019-03-09 16:29:03', NULL, NULL, 6, '打开外部链接', 'news', 'http://www.baidu.com');

-- ----------------------------
-- Table structure for t_cms_channel
-- ----------------------------
DROP TABLE IF EXISTS `t_cms_channel`;
CREATE TABLE `t_cms_channel`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '编码',
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '文章栏目' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_cms_channel
-- ----------------------------
INSERT INTO `t_cms_channel` VALUES (1, NULL, NULL, 1, '2019-03-13 22:52:46', 'news', '动态资讯');
INSERT INTO `t_cms_channel` VALUES (2, NULL, NULL, 1, '2019-03-13 22:53:11', 'product', '产品服务');
INSERT INTO `t_cms_channel` VALUES (3, NULL, NULL, 1, '2019-03-13 22:53:37', 'solution', '解决方案');
INSERT INTO `t_cms_channel` VALUES (4, NULL, NULL, 1, '2019-03-13 22:53:41', 'case', '精选案例');

-- ----------------------------
-- Table structure for t_cms_contacts
-- ----------------------------
DROP TABLE IF EXISTS `t_cms_contacts`;
CREATE TABLE `t_cms_contacts`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `email` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '电子邮箱',
  `mobile` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `remark` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  `user_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '邀约人名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '邀约信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_cms_contacts
-- ----------------------------
INSERT INTO `t_cms_contacts` VALUES (1, NULL, '2019-07-31 17:44:27', NULL, '2019-07-31 17:44:27', 'test@qq.com', '15011111111', '测试联系，哈哈哈', '张三');

-- ----------------------------
-- Table structure for t_message
-- ----------------------------
DROP TABLE IF EXISTS `t_message`;
CREATE TABLE `t_message`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `content` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息内容',
  `receiver` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '接收者',
  `state` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息类型,0:初始,1:成功,2:失败',
  `tpl_code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模板编码',
  `type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息类型,0:短信,1:邮件',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '历史消息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_message
-- ----------------------------
INSERT INTO `t_message` VALUES (1, NULL, '2019-06-10 21:20:16', NULL, NULL, '【腾讯云】校验码1032，请于5分钟内完成验证，如非本人操作请忽略本短信。', '15021592814', '2', 'REGISTER_CODE', '0');

-- ----------------------------
-- Table structure for t_message_sender
-- ----------------------------
DROP TABLE IF EXISTS `t_message_sender`;
CREATE TABLE `t_message_sender`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `class_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发送类',
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '名称',
  `tpl_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '短信运营商模板编号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '消息发送者' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_message_sender
-- ----------------------------
INSERT INTO `t_message_sender` VALUES (1, NULL, NULL, NULL, NULL, 'tencentSmsSender', ' 腾讯短信服务', NULL);
INSERT INTO `t_message_sender` VALUES (2, NULL, NULL, NULL, NULL, 'defaultEmailSender', '默认邮件发送器', NULL);

-- ----------------------------
-- Table structure for t_message_template
-- ----------------------------
DROP TABLE IF EXISTS `t_message_template`;
CREATE TABLE `t_message_template`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '编号',
  `cond` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发送条件',
  `content` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '内容',
  `id_message_sender` bigint(20) NOT NULL COMMENT '发送者id',
  `title` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标题',
  `type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息类型,0:短信,1:邮件',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK942sadqk5x9kbrwil0psyek3n`(`id_message_sender`) USING BTREE,
  CONSTRAINT `FK942sadqk5x9kbrwil0psyek3n` FOREIGN KEY (`id_message_sender`) REFERENCES `t_message_sender` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '消息模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_message_template
-- ----------------------------
INSERT INTO `t_message_template` VALUES (1, NULL, NULL, NULL, NULL, 'REGISTER_CODE', '注册页面，点击获取验证码', '【腾讯云】校验码{1}，请于5分钟内完成验证，如非本人操作请忽略本短信。', 1, '注册验证码', '0');
INSERT INTO `t_message_template` VALUES (2, NULL, NULL, NULL, NULL, 'EMAIL_TEST', '测试发送', '你好:{1},欢迎使用{2}', 2, '测试邮件', '1');
INSERT INTO `t_message_template` VALUES (3, NULL, NULL, NULL, NULL, 'EMAIL_HTML_TEMPLATE_TEST', '测试发送模板邮件', '你好<strong>${userName}</strong>欢迎使用<font color=\"red\">${appName}</font>,这是html模板邮件', 2, '测试发送模板邮件', '1');

-- ----------------------------
-- Table structure for t_sys_cfg
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_cfg`;
CREATE TABLE `t_sys_cfg`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `cfg_desc` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  `cfg_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '参数名',
  `cfg_value` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '参数值',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统参数' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_cfg
-- ----------------------------
INSERT INTO `t_sys_cfg` VALUES (1, NULL, NULL, -1, '2021-05-14 17:00:00', 'update by 2021-05-14 17:00:00', 'system.app.name', 'flash-waimai');
INSERT INTO `t_sys_cfg` VALUES (2, NULL, NULL, 1, '2019-04-15 21:36:17', '系统默认上传文件路径', 'system.file.upload.path', 'C:\\Users\\FuLin\\Desktop\\wm\\upload');
INSERT INTO `t_sys_cfg` VALUES (3, NULL, NULL, 1, '2019-04-15 21:36:17', '腾讯sms接口appid', 'api.tencent.sms.appid', '1400219425');
INSERT INTO `t_sys_cfg` VALUES (4, NULL, NULL, 1, '2019-04-15 21:36:17', '腾讯sms接口appkey', 'api.tencent.sms.appkey', '5f71ed5325f3b292946530a1773e997a');
INSERT INTO `t_sys_cfg` VALUES (5, NULL, NULL, 1, '2019-04-15 21:36:17', '腾讯sms接口签名参数', 'api.tencent.sms.sign', '需要去申请咯');
INSERT INTO `t_sys_cfg` VALUES (6, NULL, NULL, 1, '2021-05-14 16:59:49', '平台盈利额', 'system.platform.total.amount', '-5.80');
INSERT INTO `t_sys_cfg` VALUES (7, NULL, NULL, 1, '2021-05-13 22:59:20', '小程序appid', 'api.tencent.mini.program.appid', 'wx234234234234234');
INSERT INTO `t_sys_cfg` VALUES (8, NULL, NULL, 1, '2021-05-13 22:59:20', '小程序appsecret', 'api.tencent.mini.program.secret', '234234234234');

-- ----------------------------
-- Table structure for t_sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_dept`;
CREATE TABLE `t_sys_dept`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `fullname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `num` int(11) NULL DEFAULT NULL,
  `pid` bigint(20) NULL DEFAULT NULL,
  `pids` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `simplename` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `tips` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `version` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '部门' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_dept
-- ----------------------------
INSERT INTO `t_sys_dept` VALUES (24, NULL, NULL, NULL, NULL, '总公司', 1, 0, '[0],', '总公司', '', NULL);
INSERT INTO `t_sys_dept` VALUES (25, NULL, NULL, NULL, NULL, '开发部', 2, 24, '[0],[24],', '开发部', '', NULL);
INSERT INTO `t_sys_dept` VALUES (26, NULL, NULL, NULL, NULL, '运营部', 3, 24, '[0],[24],', '运营部', '', NULL);
INSERT INTO `t_sys_dept` VALUES (27, NULL, NULL, NULL, NULL, '战略部', 4, 24, '[0],[24],', '战略部', '', NULL);

-- ----------------------------
-- Table structure for t_sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_dict`;
CREATE TABLE `t_sys_dict`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `num` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `pid` bigint(20) NULL DEFAULT NULL,
  `tips` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '字典' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_dict
-- ----------------------------
INSERT INTO `t_sys_dict` VALUES (16, NULL, NULL, NULL, NULL, '状态', '0', 0, NULL);
INSERT INTO `t_sys_dict` VALUES (17, NULL, NULL, NULL, NULL, '启用', '1', 16, NULL);
INSERT INTO `t_sys_dict` VALUES (18, NULL, NULL, NULL, NULL, '禁用', '2', 16, NULL);
INSERT INTO `t_sys_dict` VALUES (29, NULL, NULL, NULL, NULL, '性别', '0', 0, NULL);
INSERT INTO `t_sys_dict` VALUES (30, NULL, NULL, NULL, NULL, '男', '1', 29, NULL);
INSERT INTO `t_sys_dict` VALUES (31, NULL, NULL, NULL, NULL, '女', '2', 29, NULL);
INSERT INTO `t_sys_dict` VALUES (35, NULL, NULL, NULL, NULL, '账号状态', '0', 0, NULL);
INSERT INTO `t_sys_dict` VALUES (36, NULL, NULL, NULL, NULL, '启用', '1', 35, NULL);
INSERT INTO `t_sys_dict` VALUES (37, NULL, NULL, NULL, NULL, '冻结', '2', 35, NULL);
INSERT INTO `t_sys_dict` VALUES (38, NULL, NULL, NULL, NULL, '已删除', '3', 35, NULL);
INSERT INTO `t_sys_dict` VALUES (53, NULL, NULL, NULL, NULL, '证件类型', '0', 0, NULL);
INSERT INTO `t_sys_dict` VALUES (54, NULL, NULL, NULL, NULL, '身份证', '1', 53, NULL);
INSERT INTO `t_sys_dict` VALUES (55, NULL, NULL, NULL, NULL, '护照', '2', 53, NULL);
INSERT INTO `t_sys_dict` VALUES (68, 1, '2019-01-13 14:18:21', 1, '2019-01-13 14:18:21', '是否', '0', 0, NULL);
INSERT INTO `t_sys_dict` VALUES (69, 1, '2019-01-13 14:18:21', 1, '2019-01-13 14:18:21', '是', '1', 68, NULL);
INSERT INTO `t_sys_dict` VALUES (70, 1, '2019-01-13 14:18:21', 1, '2019-01-13 14:18:21', '否', '0', 68, NULL);

-- ----------------------------
-- Table structure for t_sys_file_info
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_file_info`;
CREATE TABLE `t_sys_file_info`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `original_file_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `real_file_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1901 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '文件' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_file_info
-- ----------------------------
INSERT INTO `t_sys_file_info` VALUES (1, NULL, NULL, NULL, NULL, '167e8f5c43624736.png', '167e8f5c43624736.png');
INSERT INTO `t_sys_file_info` VALUES (2, NULL, NULL, NULL, NULL, '042a74e4-38b7-4c06-881b-3b7499ef9e82.jpg', '042a74e4-38b7-4c06-881b-3b7499ef9e82.jpg');
INSERT INTO `t_sys_file_info` VALUES (3, NULL, NULL, NULL, NULL, '115a034d-0dc9-44f3-b423-c93a3fcf5931.jpg', '115a034d-0dc9-44f3-b423-c93a3fcf5931.jpg');
INSERT INTO `t_sys_file_info` VALUES (4, NULL, NULL, NULL, NULL, '164ad0b6a3917599.jpg', '164ad0b6a3917599.jpg');
INSERT INTO `t_sys_file_info` VALUES (5, NULL, NULL, NULL, NULL, '1672a6af88622087.png', '1672a6af88622087.png');
INSERT INTO `t_sys_file_info` VALUES (6, NULL, NULL, NULL, NULL, '1673a5f9e3e22383.jpg', '1673a5f9e3e22383.jpg');
INSERT INTO `t_sys_file_info` VALUES (7, NULL, NULL, NULL, NULL, '1674daed4ae22611.jpeg', '1674daed4ae22611.jpeg');
INSERT INTO `t_sys_file_info` VALUES (8, NULL, NULL, NULL, NULL, '1674ddda63c22621.jpg', '1674ddda63c22621.jpg');
INSERT INTO `t_sys_file_info` VALUES (9, NULL, NULL, NULL, NULL, '1674de7de4a22623.jpg', '1674de7de4a22623.jpg');
INSERT INTO `t_sys_file_info` VALUES (10, NULL, NULL, NULL, NULL, '1674e7928c122660.jpg', '1674e7928c122660.jpg');
INSERT INTO `t_sys_file_info` VALUES (11, NULL, NULL, NULL, NULL, '1674f3b6d4322699.jpg', '1674f3b6d4322699.jpg');
INSERT INTO `t_sys_file_info` VALUES (12, NULL, NULL, NULL, NULL, '1674f755aa622706.png', '1674f755aa622706.png');
INSERT INTO `t_sys_file_info` VALUES (13, NULL, NULL, NULL, NULL, '1674f7622b322709.png', '1674f7622b322709.png');
INSERT INTO `t_sys_file_info` VALUES (14, NULL, NULL, NULL, NULL, '1674f76c02d22710.png', '1674f76c02d22710.png');
INSERT INTO `t_sys_file_info` VALUES (15, NULL, NULL, NULL, NULL, '16752b8856222736.png', '16752b8856222736.png');
INSERT INTO `t_sys_file_info` VALUES (16, NULL, NULL, NULL, NULL, '16753607a9f22759.jpg', '16753607a9f22759.jpg');
INSERT INTO `t_sys_file_info` VALUES (17, NULL, NULL, NULL, NULL, '16753dce3a422773.png', '16753dce3a422773.png');
INSERT INTO `t_sys_file_info` VALUES (18, NULL, NULL, NULL, NULL, '16754543a8b22795.jpg', '16754543a8b22795.jpg');
INSERT INTO `t_sys_file_info` VALUES (19, NULL, NULL, NULL, NULL, '1675455928722796.jpg', '1675455928722796.jpg');
INSERT INTO `t_sys_file_info` VALUES (20, NULL, NULL, NULL, NULL, '16754b9a3d122819.jpg', '16754b9a3d122819.jpg');
INSERT INTO `t_sys_file_info` VALUES (21, NULL, NULL, NULL, NULL, '16754c1ee2d22822.jpg', '16754c1ee2d22822.jpg');
INSERT INTO `t_sys_file_info` VALUES (22, NULL, NULL, NULL, NULL, '16754cd937122823.jpg', '16754cd937122823.jpg');
INSERT INTO `t_sys_file_info` VALUES (23, NULL, NULL, NULL, NULL, '16754ceeaed22824.jpg', '16754ceeaed22824.jpg');
INSERT INTO `t_sys_file_info` VALUES (24, NULL, NULL, NULL, NULL, '167551d3b6422829.png', '167551d3b6422829.png');
INSERT INTO `t_sys_file_info` VALUES (25, NULL, NULL, NULL, NULL, '167551dbdeb22830.png', '167551dbdeb22830.png');
INSERT INTO `t_sys_file_info` VALUES (26, NULL, NULL, NULL, NULL, '16755208c4e22831.jpg', '16755208c4e22831.jpg');
INSERT INTO `t_sys_file_info` VALUES (27, NULL, NULL, NULL, NULL, '16755212e9e22832.png', '16755212e9e22832.png');
INSERT INTO `t_sys_file_info` VALUES (28, NULL, NULL, NULL, NULL, '16755248f8e22833.png', '16755248f8e22833.png');
INSERT INTO `t_sys_file_info` VALUES (29, NULL, NULL, NULL, NULL, '16757ed9aca22835.png', '16757ed9aca22835.png');
INSERT INTO `t_sys_file_info` VALUES (30, NULL, NULL, NULL, NULL, '167583df1c022845.png', '167583df1c022845.png');
INSERT INTO `t_sys_file_info` VALUES (31, NULL, NULL, NULL, NULL, '1675851c03622848.jpg', '1675851c03622848.jpg');
INSERT INTO `t_sys_file_info` VALUES (32, NULL, NULL, NULL, NULL, '167596f7cd722877.png', '167596f7cd722877.png');
INSERT INTO `t_sys_file_info` VALUES (33, NULL, NULL, NULL, NULL, '16759b4c0aa22892.png', '16759b4c0aa22892.png');
INSERT INTO `t_sys_file_info` VALUES (34, NULL, NULL, NULL, NULL, '1675cf8c3db22903.png', '1675cf8c3db22903.png');
INSERT INTO `t_sys_file_info` VALUES (35, NULL, NULL, NULL, NULL, '1675d7dc9fe22917.jpg', '1675d7dc9fe22917.jpg');
INSERT INTO `t_sys_file_info` VALUES (36, NULL, NULL, NULL, NULL, '1675e44182b22953.png', '1675e44182b22953.png');
INSERT INTO `t_sys_file_info` VALUES (37, NULL, NULL, NULL, NULL, '1675e7cf53222965.png', '1675e7cf53222965.png');
INSERT INTO `t_sys_file_info` VALUES (38, NULL, NULL, NULL, NULL, '1675e949ae922971.png', '1675e949ae922971.png');
INSERT INTO `t_sys_file_info` VALUES (39, NULL, NULL, NULL, NULL, '1675ec6125a22973.png', '1675ec6125a22973.png');
INSERT INTO `t_sys_file_info` VALUES (40, NULL, NULL, NULL, NULL, '1675f0a4de022977.jpg', '1675f0a4de022977.jpg');
INSERT INTO `t_sys_file_info` VALUES (41, NULL, NULL, NULL, NULL, '1676207f67822984.jpg', '1676207f67822984.jpg');
INSERT INTO `t_sys_file_info` VALUES (42, NULL, NULL, NULL, NULL, '1676365dc5f23022.jpg', '1676365dc5f23022.jpg');
INSERT INTO `t_sys_file_info` VALUES (43, NULL, NULL, NULL, NULL, '16763ad1b0823027.png', '16763ad1b0823027.png');
INSERT INTO `t_sys_file_info` VALUES (44, NULL, NULL, NULL, NULL, '16763f8ce3223046.jpeg', '16763f8ce3223046.jpeg');
INSERT INTO `t_sys_file_info` VALUES (45, NULL, NULL, NULL, NULL, '1676e797fc423084.jpeg', '1676e797fc423084.jpeg');
INSERT INTO `t_sys_file_info` VALUES (46, NULL, NULL, NULL, NULL, '1676ea4ec9123089.jpg', '1676ea4ec9123089.jpg');
INSERT INTO `t_sys_file_info` VALUES (47, NULL, NULL, NULL, NULL, '16771ed943323124.png', '16771ed943323124.png');
INSERT INTO `t_sys_file_info` VALUES (48, NULL, NULL, NULL, NULL, '16772d91c1823153.jpg', '16772d91c1823153.jpg');
INSERT INTO `t_sys_file_info` VALUES (49, NULL, NULL, NULL, NULL, '16772edcbfa23161.jpg', '16772edcbfa23161.jpg');
INSERT INTO `t_sys_file_info` VALUES (50, NULL, NULL, NULL, NULL, '16772ee8ba123162.jpg', '16772ee8ba123162.jpg');
INSERT INTO `t_sys_file_info` VALUES (51, NULL, NULL, NULL, NULL, '16772f6e14e23166.jpg', '16772f6e14e23166.jpg');
INSERT INTO `t_sys_file_info` VALUES (52, NULL, NULL, NULL, NULL, '16772f7e23023167.jpg', '16772f7e23023167.jpg');
INSERT INTO `t_sys_file_info` VALUES (53, NULL, NULL, NULL, NULL, '16773003b2c23168.jpg', '16773003b2c23168.jpg');
INSERT INTO `t_sys_file_info` VALUES (54, NULL, NULL, NULL, NULL, '1677352ff2523175.jpeg', '1677352ff2523175.jpeg');
INSERT INTO `t_sys_file_info` VALUES (55, NULL, NULL, NULL, NULL, '167736791fd23178.jpg', '167736791fd23178.jpg');
INSERT INTO `t_sys_file_info` VALUES (56, NULL, NULL, NULL, NULL, '167746075eb23195.jpg', '167746075eb23195.jpg');
INSERT INTO `t_sys_file_info` VALUES (57, NULL, NULL, NULL, NULL, '16776f4272223206.jpg', '16776f4272223206.jpg');
INSERT INTO `t_sys_file_info` VALUES (58, NULL, NULL, NULL, NULL, '167775c8fc223218.png', '167775c8fc223218.png');
INSERT INTO `t_sys_file_info` VALUES (59, NULL, NULL, NULL, NULL, '167778375e623220.png', '167778375e623220.png');
INSERT INTO `t_sys_file_info` VALUES (60, NULL, NULL, NULL, NULL, '167785404c923224.png', '167785404c923224.png');
INSERT INTO `t_sys_file_info` VALUES (61, NULL, NULL, NULL, NULL, '167787084f123226.png', '167787084f123226.png');
INSERT INTO `t_sys_file_info` VALUES (62, NULL, NULL, NULL, NULL, '167799f2a4e23249.png', '167799f2a4e23249.png');
INSERT INTO `t_sys_file_info` VALUES (63, NULL, NULL, NULL, NULL, '16779b656d323252.jpg', '16779b656d323252.jpg');
INSERT INTO `t_sys_file_info` VALUES (64, NULL, NULL, NULL, NULL, '1677c1bffa123261.jpg', '1677c1bffa123261.jpg');
INSERT INTO `t_sys_file_info` VALUES (65, NULL, NULL, NULL, NULL, '1677c2c183e23265.jpg', '1677c2c183e23265.jpg');
INSERT INTO `t_sys_file_info` VALUES (66, NULL, NULL, NULL, NULL, '1677c30654123268.jpg', '1677c30654123268.jpg');
INSERT INTO `t_sys_file_info` VALUES (67, NULL, NULL, NULL, NULL, '1677cd4e28123283.png', '1677cd4e28123283.png');
INSERT INTO `t_sys_file_info` VALUES (68, NULL, NULL, NULL, NULL, '1677cff6cbf23286.jpg', '1677cff6cbf23286.jpg');
INSERT INTO `t_sys_file_info` VALUES (69, NULL, NULL, NULL, NULL, '1677d00cb0023288.jpg', '1677d00cb0023288.jpg');
INSERT INTO `t_sys_file_info` VALUES (70, NULL, NULL, NULL, NULL, '1677d15f3ad23289.png', '1677d15f3ad23289.png');
INSERT INTO `t_sys_file_info` VALUES (71, NULL, NULL, NULL, NULL, '1677d5cf0ae23309.jpg', '1677d5cf0ae23309.jpg');
INSERT INTO `t_sys_file_info` VALUES (72, NULL, NULL, NULL, NULL, '1677d71338723312.jpg', '1677d71338723312.jpg');
INSERT INTO `t_sys_file_info` VALUES (73, NULL, NULL, NULL, NULL, '1677dd81a9823324.jpeg', '1677dd81a9823324.jpeg');
INSERT INTO `t_sys_file_info` VALUES (74, NULL, NULL, NULL, NULL, '1677ddd4ace23325.jpeg', '1677ddd4ace23325.jpeg');
INSERT INTO `t_sys_file_info` VALUES (75, NULL, NULL, NULL, NULL, '1678122dd6223332.jpg', '1678122dd6223332.jpg');
INSERT INTO `t_sys_file_info` VALUES (76, NULL, NULL, NULL, NULL, '167814d9bb723335.jpg', '167814d9bb723335.jpg');
INSERT INTO `t_sys_file_info` VALUES (77, NULL, NULL, NULL, NULL, '1678178095423339.jpg', '1678178095423339.jpg');
INSERT INTO `t_sys_file_info` VALUES (78, NULL, NULL, NULL, NULL, '167817a8e3123341.jpg', '167817a8e3123341.jpg');
INSERT INTO `t_sys_file_info` VALUES (79, NULL, NULL, NULL, NULL, '167822aa37523351.png', '167822aa37523351.png');
INSERT INTO `t_sys_file_info` VALUES (80, NULL, NULL, NULL, NULL, '16782636c8f23355.jpg', '16782636c8f23355.jpg');
INSERT INTO `t_sys_file_info` VALUES (81, NULL, NULL, NULL, NULL, '167827755ee23358.jpg', '167827755ee23358.jpg');
INSERT INTO `t_sys_file_info` VALUES (82, NULL, NULL, NULL, NULL, '16782f2b36423365.jpg', '16782f2b36423365.jpg');
INSERT INTO `t_sys_file_info` VALUES (83, NULL, NULL, NULL, NULL, '1678311693b23367.png', '1678311693b23367.png');
INSERT INTO `t_sys_file_info` VALUES (84, NULL, NULL, NULL, NULL, '16784163e3d23374.jpg', '16784163e3d23374.jpg');
INSERT INTO `t_sys_file_info` VALUES (85, NULL, NULL, NULL, NULL, '167842a484823380.png', '167842a484823380.png');
INSERT INTO `t_sys_file_info` VALUES (86, NULL, NULL, NULL, NULL, '1678624e9a623383.png', '1678624e9a623383.png');
INSERT INTO `t_sys_file_info` VALUES (87, NULL, NULL, NULL, NULL, '1678651efaf23395.png', '1678651efaf23395.png');
INSERT INTO `t_sys_file_info` VALUES (88, NULL, NULL, NULL, NULL, '1678696714d23399.jpg', '1678696714d23399.jpg');
INSERT INTO `t_sys_file_info` VALUES (89, NULL, NULL, NULL, NULL, '1678743dbf423408.jpg', '1678743dbf423408.jpg');
INSERT INTO `t_sys_file_info` VALUES (90, NULL, NULL, NULL, NULL, '1678748388a23409.jpg', '1678748388a23409.jpg');
INSERT INTO `t_sys_file_info` VALUES (91, NULL, NULL, NULL, NULL, '167874885f923410.jpg', '167874885f923410.jpg');
INSERT INTO `t_sys_file_info` VALUES (92, NULL, NULL, NULL, NULL, '167875094f023411.png', '167875094f023411.png');
INSERT INTO `t_sys_file_info` VALUES (93, NULL, NULL, NULL, NULL, '1678755af9e23412.jpg', '1678755af9e23412.jpg');
INSERT INTO `t_sys_file_info` VALUES (94, NULL, NULL, NULL, NULL, '167878387a023419.png', '167878387a023419.png');
INSERT INTO `t_sys_file_info` VALUES (95, NULL, NULL, NULL, NULL, '16787a80cd323432.png', '16787a80cd323432.png');
INSERT INTO `t_sys_file_info` VALUES (96, NULL, NULL, NULL, NULL, '16787dec5be23437.png', '16787dec5be23437.png');
INSERT INTO `t_sys_file_info` VALUES (97, NULL, NULL, NULL, NULL, '16787e2a55f23439.png', '16787e2a55f23439.png');
INSERT INTO `t_sys_file_info` VALUES (98, NULL, NULL, NULL, NULL, '167896dd9dd23459.jpg', '167896dd9dd23459.jpg');
INSERT INTO `t_sys_file_info` VALUES (99, NULL, NULL, NULL, NULL, '1678b84ec6b23464.jpg', '1678b84ec6b23464.jpg');
INSERT INTO `t_sys_file_info` VALUES (100, NULL, NULL, NULL, NULL, '1678c8ee38e23470.png', '1678c8ee38e23470.png');
INSERT INTO `t_sys_file_info` VALUES (101, NULL, NULL, NULL, NULL, '1678cbc185923474.jpg', '1678cbc185923474.jpg');
INSERT INTO `t_sys_file_info` VALUES (102, NULL, NULL, NULL, NULL, '1678cbd5b2923475.jpg', '1678cbd5b2923475.jpg');
INSERT INTO `t_sys_file_info` VALUES (103, NULL, NULL, NULL, NULL, '1678cce6ce923476.png', '1678cce6ce923476.png');
INSERT INTO `t_sys_file_info` VALUES (104, NULL, NULL, NULL, NULL, '1678cebbda323478.png', '1678cebbda323478.png');
INSERT INTO `t_sys_file_info` VALUES (105, NULL, NULL, NULL, NULL, '1678d1b789523485.png', '1678d1b789523485.png');
INSERT INTO `t_sys_file_info` VALUES (106, NULL, NULL, NULL, NULL, '1678da007c623487.jpg', '1678da007c623487.jpg');
INSERT INTO `t_sys_file_info` VALUES (107, NULL, NULL, NULL, NULL, '1678dab6cf223488.jpg', '1678dab6cf223488.jpg');
INSERT INTO `t_sys_file_info` VALUES (108, NULL, NULL, NULL, NULL, '1678e9ab98523491.jpg', '1678e9ab98523491.jpg');
INSERT INTO `t_sys_file_info` VALUES (109, NULL, NULL, NULL, NULL, '16793546e2323503.jpg', '16793546e2323503.jpg');
INSERT INTO `t_sys_file_info` VALUES (110, NULL, NULL, NULL, NULL, '16796112abf23509.jpeg', '16796112abf23509.jpeg');
INSERT INTO `t_sys_file_info` VALUES (111, NULL, NULL, NULL, NULL, '16796a1e3d923514.jpg', '16796a1e3d923514.jpg');
INSERT INTO `t_sys_file_info` VALUES (112, NULL, NULL, NULL, NULL, '16796af842723518.jpg', '16796af842723518.jpg');
INSERT INTO `t_sys_file_info` VALUES (113, NULL, NULL, NULL, NULL, '16796b08be923519.jpg', '16796b08be923519.jpg');
INSERT INTO `t_sys_file_info` VALUES (114, NULL, NULL, NULL, NULL, '16796b2740d23520.jpg', '16796b2740d23520.jpg');
INSERT INTO `t_sys_file_info` VALUES (115, NULL, NULL, NULL, NULL, '16796b6139a23523.jpg', '16796b6139a23523.jpg');
INSERT INTO `t_sys_file_info` VALUES (116, NULL, NULL, NULL, NULL, '16796d87ae823530.png', '16796d87ae823530.png');
INSERT INTO `t_sys_file_info` VALUES (117, NULL, NULL, NULL, NULL, '16796dcdb0d23531.png', '16796dcdb0d23531.png');
INSERT INTO `t_sys_file_info` VALUES (118, NULL, NULL, NULL, NULL, '16796e7a38223536.jpg', '16796e7a38223536.jpg');
INSERT INTO `t_sys_file_info` VALUES (119, NULL, NULL, NULL, NULL, '167970e90ab23540.png', '167970e90ab23540.png');
INSERT INTO `t_sys_file_info` VALUES (120, NULL, NULL, NULL, NULL, '167971281cd23541.png', '167971281cd23541.png');
INSERT INTO `t_sys_file_info` VALUES (121, NULL, NULL, NULL, NULL, '1679714586823542.jpg', '1679714586823542.jpg');
INSERT INTO `t_sys_file_info` VALUES (122, NULL, NULL, NULL, NULL, '1679742eab823543.jpeg', '1679742eab823543.jpeg');
INSERT INTO `t_sys_file_info` VALUES (123, NULL, NULL, NULL, NULL, '16797583aee23551.png', '16797583aee23551.png');
INSERT INTO `t_sys_file_info` VALUES (124, NULL, NULL, NULL, NULL, '1679792641d23553.png', '1679792641d23553.png');
INSERT INTO `t_sys_file_info` VALUES (125, NULL, NULL, NULL, NULL, '16797d9bc3e23557.jpg', '16797d9bc3e23557.jpg');
INSERT INTO `t_sys_file_info` VALUES (126, NULL, NULL, NULL, NULL, '167984a265e23567.png', '167984a265e23567.png');
INSERT INTO `t_sys_file_info` VALUES (127, NULL, NULL, NULL, NULL, '167988edeeb23570.jpg', '167988edeeb23570.jpg');
INSERT INTO `t_sys_file_info` VALUES (128, NULL, NULL, NULL, NULL, '1679ad7cec923576.jpg', '1679ad7cec923576.jpg');
INSERT INTO `t_sys_file_info` VALUES (129, NULL, NULL, NULL, NULL, '1679afd28ed23578.jpg', '1679afd28ed23578.jpg');
INSERT INTO `t_sys_file_info` VALUES (130, NULL, NULL, NULL, NULL, '1679b0ed57523581.png', '1679b0ed57523581.png');
INSERT INTO `t_sys_file_info` VALUES (131, NULL, NULL, NULL, NULL, '1679b2ec00a23582.jpg', '1679b2ec00a23582.jpg');
INSERT INTO `t_sys_file_info` VALUES (132, NULL, NULL, NULL, NULL, '1679c1220f223613.png', '1679c1220f223613.png');
INSERT INTO `t_sys_file_info` VALUES (133, NULL, NULL, NULL, NULL, '1679c1820db23615.jpg', '1679c1820db23615.jpg');
INSERT INTO `t_sys_file_info` VALUES (134, NULL, NULL, NULL, NULL, '1679c19d0cf23617.jpg', '1679c19d0cf23617.jpg');
INSERT INTO `t_sys_file_info` VALUES (135, NULL, NULL, NULL, NULL, '1679c27357323619.jpg', '1679c27357323619.jpg');
INSERT INTO `t_sys_file_info` VALUES (136, NULL, NULL, NULL, NULL, '1679c294a7223620.jpg', '1679c294a7223620.jpg');
INSERT INTO `t_sys_file_info` VALUES (137, NULL, NULL, NULL, NULL, '1679c2d9a0223624.jpg', '1679c2d9a0223624.jpg');
INSERT INTO `t_sys_file_info` VALUES (138, NULL, NULL, NULL, NULL, '1679c5646bb23629.png', '1679c5646bb23629.png');
INSERT INTO `t_sys_file_info` VALUES (139, NULL, NULL, NULL, NULL, '1679c68116623632.png', '1679c68116623632.png');
INSERT INTO `t_sys_file_info` VALUES (140, NULL, NULL, NULL, NULL, '1679cbe6eb123649.jpeg', '1679cbe6eb123649.jpeg');
INSERT INTO `t_sys_file_info` VALUES (141, NULL, NULL, NULL, NULL, '1679cbe87ca23650.jpg', '1679cbe87ca23650.jpg');
INSERT INTO `t_sys_file_info` VALUES (142, NULL, NULL, NULL, NULL, '1679cbec4f023651.png', '1679cbec4f023651.png');
INSERT INTO `t_sys_file_info` VALUES (143, NULL, NULL, NULL, NULL, '1679dff179b23654.jpg', '1679dff179b23654.jpg');
INSERT INTO `t_sys_file_info` VALUES (144, NULL, NULL, NULL, NULL, '1679e10a0fe23655.png', '1679e10a0fe23655.png');
INSERT INTO `t_sys_file_info` VALUES (145, NULL, NULL, NULL, NULL, '167a02f39c023658.jpg', '167a02f39c023658.jpg');
INSERT INTO `t_sys_file_info` VALUES (146, NULL, NULL, NULL, NULL, '167a030ae2e23661.jpg', '167a030ae2e23661.jpg');
INSERT INTO `t_sys_file_info` VALUES (147, NULL, NULL, NULL, NULL, '167a08dc31d23675.png', '167a08dc31d23675.png');
INSERT INTO `t_sys_file_info` VALUES (148, NULL, NULL, NULL, NULL, '167a0c5c72f23682.png', '167a0c5c72f23682.png');
INSERT INTO `t_sys_file_info` VALUES (149, NULL, NULL, NULL, NULL, '167a10afaf423687.png', '167a10afaf423687.png');
INSERT INTO `t_sys_file_info` VALUES (150, NULL, NULL, NULL, NULL, '167a116d30123688.jpg', '167a116d30123688.jpg');
INSERT INTO `t_sys_file_info` VALUES (151, NULL, NULL, NULL, NULL, '167a134d42623697.png', '167a134d42623697.png');
INSERT INTO `t_sys_file_info` VALUES (152, NULL, NULL, NULL, NULL, '167a156c4c123702.jpg', '167a156c4c123702.jpg');
INSERT INTO `t_sys_file_info` VALUES (153, NULL, NULL, NULL, NULL, '167a15a98b323704.jpg', '167a15a98b323704.jpg');
INSERT INTO `t_sys_file_info` VALUES (154, NULL, NULL, NULL, NULL, '167a15c9e6323707.jpg', '167a15c9e6323707.jpg');
INSERT INTO `t_sys_file_info` VALUES (155, NULL, NULL, NULL, NULL, '167a166412c23710.jpg', '167a166412c23710.jpg');
INSERT INTO `t_sys_file_info` VALUES (156, NULL, NULL, NULL, NULL, '167a1a07b9123726.jpg', '167a1a07b9123726.jpg');
INSERT INTO `t_sys_file_info` VALUES (157, NULL, NULL, NULL, NULL, '167a527eecf23748.png', '167a527eecf23748.png');
INSERT INTO `t_sys_file_info` VALUES (158, NULL, NULL, NULL, NULL, '167a53fe1d723752.jpeg', '167a53fe1d723752.jpeg');
INSERT INTO `t_sys_file_info` VALUES (159, NULL, NULL, NULL, NULL, '167a550ffc523754.jpg', '167a550ffc523754.jpg');
INSERT INTO `t_sys_file_info` VALUES (160, NULL, NULL, NULL, NULL, '167a5bab0ca23770.png', '167a5bab0ca23770.png');
INSERT INTO `t_sys_file_info` VALUES (161, NULL, NULL, NULL, NULL, '167a62e6e9623774.jpg', '167a62e6e9623774.jpg');
INSERT INTO `t_sys_file_info` VALUES (162, NULL, NULL, NULL, NULL, '167a633321523776.png', '167a633321523776.png');
INSERT INTO `t_sys_file_info` VALUES (163, NULL, NULL, NULL, NULL, '167a633e91423777.png', '167a633e91423777.png');
INSERT INTO `t_sys_file_info` VALUES (164, NULL, NULL, NULL, NULL, '167a645562623778.png', '167a645562623778.png');
INSERT INTO `t_sys_file_info` VALUES (165, NULL, NULL, NULL, NULL, '167a64e3a4823781.jpg', '167a64e3a4823781.jpg');
INSERT INTO `t_sys_file_info` VALUES (166, NULL, NULL, NULL, NULL, '167a6519ae423783.jpg', '167a6519ae423783.jpg');
INSERT INTO `t_sys_file_info` VALUES (167, NULL, NULL, NULL, NULL, '167a65ae0f323787.jpg', '167a65ae0f323787.jpg');
INSERT INTO `t_sys_file_info` VALUES (168, NULL, NULL, NULL, NULL, '167a68e488c23794.jpg', '167a68e488c23794.jpg');
INSERT INTO `t_sys_file_info` VALUES (169, NULL, NULL, NULL, NULL, '167a756320123814.jpg', '167a756320123814.jpg');
INSERT INTO `t_sys_file_info` VALUES (170, NULL, NULL, NULL, NULL, '167a7de2ca923818.jpg', '167a7de2ca923818.jpg');
INSERT INTO `t_sys_file_info` VALUES (171, NULL, NULL, NULL, NULL, '167aa6aadc123828.png', '167aa6aadc123828.png');
INSERT INTO `t_sys_file_info` VALUES (172, NULL, NULL, NULL, NULL, '167aa8f46e923829.jpg', '167aa8f46e923829.jpg');
INSERT INTO `t_sys_file_info` VALUES (173, NULL, NULL, NULL, NULL, '167aaa85fd623835.png', '167aaa85fd623835.png');
INSERT INTO `t_sys_file_info` VALUES (174, NULL, NULL, NULL, NULL, '167aaa9c0b623836.png', '167aaa9c0b623836.png');
INSERT INTO `t_sys_file_info` VALUES (175, NULL, NULL, NULL, NULL, '167ab87ab3223851.jpg', '167ab87ab3223851.jpg');
INSERT INTO `t_sys_file_info` VALUES (176, NULL, NULL, NULL, NULL, '167abb54f6623864.png', '167abb54f6623864.png');
INSERT INTO `t_sys_file_info` VALUES (177, NULL, NULL, NULL, NULL, '167abb6e09523865.png', '167abb6e09523865.png');
INSERT INTO `t_sys_file_info` VALUES (178, NULL, NULL, NULL, NULL, '167afdbb9ca23927.jpg', '167afdbb9ca23927.jpg');
INSERT INTO `t_sys_file_info` VALUES (179, NULL, NULL, NULL, NULL, '167b102228423947.png', '167b102228423947.png');
INSERT INTO `t_sys_file_info` VALUES (180, NULL, NULL, NULL, NULL, '167b227780423958.jpeg', '167b227780423958.jpeg');
INSERT INTO `t_sys_file_info` VALUES (181, NULL, NULL, NULL, NULL, '167b24c1ac023962.jpg', '167b24c1ac023962.jpg');
INSERT INTO `t_sys_file_info` VALUES (182, NULL, NULL, NULL, NULL, '167b5f3135923973.jpg', '167b5f3135923973.jpg');
INSERT INTO `t_sys_file_info` VALUES (183, NULL, NULL, NULL, NULL, '167b5fa71c823975.jpg', '167b5fa71c823975.jpg');
INSERT INTO `t_sys_file_info` VALUES (184, NULL, NULL, NULL, NULL, '167b657883123978.jpg', '167b657883123978.jpg');
INSERT INTO `t_sys_file_info` VALUES (185, NULL, NULL, NULL, NULL, '167b6cd4a3623984.png', '167b6cd4a3623984.png');
INSERT INTO `t_sys_file_info` VALUES (186, NULL, NULL, NULL, NULL, '167b7560ea923987.jpg', '167b7560ea923987.jpg');
INSERT INTO `t_sys_file_info` VALUES (187, NULL, NULL, NULL, NULL, '167b75743f423988.jpg', '167b75743f423988.jpg');
INSERT INTO `t_sys_file_info` VALUES (188, NULL, NULL, NULL, NULL, '167b75b067223989.jpg', '167b75b067223989.jpg');
INSERT INTO `t_sys_file_info` VALUES (189, NULL, NULL, NULL, NULL, '167b75c0d4023990.jpg', '167b75c0d4023990.jpg');
INSERT INTO `t_sys_file_info` VALUES (190, NULL, NULL, NULL, NULL, '167b75e810e23991.jpg', '167b75e810e23991.jpg');
INSERT INTO `t_sys_file_info` VALUES (191, NULL, NULL, NULL, NULL, '167b7ebf89923994.jpeg', '167b7ebf89923994.jpeg');
INSERT INTO `t_sys_file_info` VALUES (192, NULL, NULL, NULL, NULL, '167b9f71eed24007.png', '167b9f71eed24007.png');
INSERT INTO `t_sys_file_info` VALUES (193, NULL, NULL, NULL, NULL, '167ba9f46c524055.png', '167ba9f46c524055.png');
INSERT INTO `t_sys_file_info` VALUES (194, NULL, NULL, NULL, NULL, '167baa65ca424056.jpg', '167baa65ca424056.jpg');
INSERT INTO `t_sys_file_info` VALUES (195, NULL, NULL, NULL, NULL, '167bae9a73224069.png', '167bae9a73224069.png');
INSERT INTO `t_sys_file_info` VALUES (196, NULL, NULL, NULL, NULL, '167bb0cbb5824076.jpg', '167bb0cbb5824076.jpg');
INSERT INTO `t_sys_file_info` VALUES (197, NULL, NULL, NULL, NULL, '167bb0dfb8f24077.jpg', '167bb0dfb8f24077.jpg');
INSERT INTO `t_sys_file_info` VALUES (198, NULL, NULL, NULL, NULL, '167bb1dac9c24082.png', '167bb1dac9c24082.png');
INSERT INTO `t_sys_file_info` VALUES (199, NULL, NULL, NULL, NULL, '167bb1ec84d24085.png', '167bb1ec84d24085.png');
INSERT INTO `t_sys_file_info` VALUES (200, NULL, NULL, NULL, NULL, '167bb21403324086.jpg', '167bb21403324086.jpg');
INSERT INTO `t_sys_file_info` VALUES (201, NULL, NULL, NULL, NULL, '167bb316c7d24090.png', '167bb316c7d24090.png');
INSERT INTO `t_sys_file_info` VALUES (202, NULL, NULL, NULL, NULL, '167bbab4c1424104.jpeg', '167bbab4c1424104.jpeg');
INSERT INTO `t_sys_file_info` VALUES (203, NULL, NULL, NULL, NULL, '167bbaf66a424107.jpeg', '167bbaf66a424107.jpeg');
INSERT INTO `t_sys_file_info` VALUES (204, NULL, NULL, NULL, NULL, '167bbb2306324108.jpeg', '167bbb2306324108.jpeg');
INSERT INTO `t_sys_file_info` VALUES (205, NULL, NULL, NULL, NULL, '167be15360b24114.jpg', '167be15360b24114.jpg');
INSERT INTO `t_sys_file_info` VALUES (206, NULL, NULL, NULL, NULL, '167beff72aa24122.png', '167beff72aa24122.png');
INSERT INTO `t_sys_file_info` VALUES (207, NULL, NULL, NULL, NULL, '167bf1dbde624131.jpg', '167bf1dbde624131.jpg');
INSERT INTO `t_sys_file_info` VALUES (208, NULL, NULL, NULL, NULL, '167c000bf9824169.jpg', '167c000bf9824169.jpg');
INSERT INTO `t_sys_file_info` VALUES (209, NULL, NULL, NULL, NULL, '167c033a32d24175.png', '167c033a32d24175.png');
INSERT INTO `t_sys_file_info` VALUES (210, NULL, NULL, NULL, NULL, '167c04a43ab24178.png', '167c04a43ab24178.png');
INSERT INTO `t_sys_file_info` VALUES (211, NULL, NULL, NULL, NULL, '167c083885d24194.png', '167c083885d24194.png');
INSERT INTO `t_sys_file_info` VALUES (212, NULL, NULL, NULL, NULL, '167c16447d024207.jpg', '167c16447d024207.jpg');
INSERT INTO `t_sys_file_info` VALUES (213, NULL, NULL, NULL, NULL, '167c1829fab24210.jpg', '167c1829fab24210.jpg');
INSERT INTO `t_sys_file_info` VALUES (214, NULL, NULL, NULL, NULL, '167c460be1924231.jpg', '167c460be1924231.jpg');
INSERT INTO `t_sys_file_info` VALUES (215, NULL, NULL, NULL, NULL, '167c47af2f824232.png', '167c47af2f824232.png');
INSERT INTO `t_sys_file_info` VALUES (216, NULL, NULL, NULL, NULL, '167c4fb282924238.jpg', '167c4fb282924238.jpg');
INSERT INTO `t_sys_file_info` VALUES (217, NULL, NULL, NULL, NULL, '167c528088324247.jpg', '167c528088324247.jpg');
INSERT INTO `t_sys_file_info` VALUES (218, NULL, NULL, NULL, NULL, '167c5e6b14d24284.jpg', '167c5e6b14d24284.jpg');
INSERT INTO `t_sys_file_info` VALUES (219, NULL, NULL, NULL, NULL, '167c5ecc4e324285.jpg', '167c5ecc4e324285.jpg');
INSERT INTO `t_sys_file_info` VALUES (220, NULL, NULL, NULL, NULL, '167c5ed8def24286.png', '167c5ed8def24286.png');
INSERT INTO `t_sys_file_info` VALUES (221, NULL, NULL, NULL, NULL, '167c5ef6df124287.png', '167c5ef6df124287.png');
INSERT INTO `t_sys_file_info` VALUES (222, NULL, NULL, NULL, NULL, '167c65652ea24293.jpg', '167c65652ea24293.jpg');
INSERT INTO `t_sys_file_info` VALUES (223, NULL, NULL, NULL, NULL, '167c69272bd24294.png', '167c69272bd24294.png');
INSERT INTO `t_sys_file_info` VALUES (224, NULL, NULL, NULL, NULL, '167c694887524297.png', '167c694887524297.png');
INSERT INTO `t_sys_file_info` VALUES (225, NULL, NULL, NULL, NULL, '167c6991c9824298.png', '167c6991c9824298.png');
INSERT INTO `t_sys_file_info` VALUES (226, NULL, NULL, NULL, NULL, '167c92aba0b24310.jpg', '167c92aba0b24310.jpg');
INSERT INTO `t_sys_file_info` VALUES (227, NULL, NULL, NULL, NULL, '167c956d4c424317.png', '167c956d4c424317.png');
INSERT INTO `t_sys_file_info` VALUES (228, NULL, NULL, NULL, NULL, '167c997658a24325.png', '167c997658a24325.png');
INSERT INTO `t_sys_file_info` VALUES (229, NULL, NULL, NULL, NULL, '167c9b2956224327.png', '167c9b2956224327.png');
INSERT INTO `t_sys_file_info` VALUES (230, NULL, NULL, NULL, NULL, '167c9c1b49924330.jpg', '167c9c1b49924330.jpg');
INSERT INTO `t_sys_file_info` VALUES (231, NULL, NULL, NULL, NULL, '167ca0c192224335.jpg', '167ca0c192224335.jpg');
INSERT INTO `t_sys_file_info` VALUES (232, NULL, NULL, NULL, NULL, '167ca4a993324342.png', '167ca4a993324342.png');
INSERT INTO `t_sys_file_info` VALUES (233, NULL, NULL, NULL, NULL, '167ca51b42524343.png', '167ca51b42524343.png');
INSERT INTO `t_sys_file_info` VALUES (234, NULL, NULL, NULL, NULL, '167ca590a9b24350.jpg', '167ca590a9b24350.jpg');
INSERT INTO `t_sys_file_info` VALUES (235, NULL, NULL, NULL, NULL, '167ca9f592024367.jpg', '167ca9f592024367.jpg');
INSERT INTO `t_sys_file_info` VALUES (236, NULL, NULL, NULL, NULL, '167ce68c5b924395.jpg', '167ce68c5b924395.jpg');
INSERT INTO `t_sys_file_info` VALUES (237, NULL, NULL, NULL, NULL, '167cea7aca524400.jpg', '167cea7aca524400.jpg');
INSERT INTO `t_sys_file_info` VALUES (238, NULL, NULL, NULL, NULL, '167ceeb4c4324413.png', '167ceeb4c4324413.png');
INSERT INTO `t_sys_file_info` VALUES (239, NULL, NULL, NULL, NULL, '167cfcb176724469.jpg', '167cfcb176724469.jpg');
INSERT INTO `t_sys_file_info` VALUES (240, NULL, NULL, NULL, NULL, '167d019736924475.jpg', '167d019736924475.jpg');
INSERT INTO `t_sys_file_info` VALUES (241, NULL, NULL, NULL, NULL, '167d01ed69124478.jpg', '167d01ed69124478.jpg');
INSERT INTO `t_sys_file_info` VALUES (242, NULL, NULL, NULL, NULL, '167db4bfa9224502.jpeg', '167db4bfa9224502.jpeg');
INSERT INTO `t_sys_file_info` VALUES (243, NULL, NULL, NULL, NULL, '167db8e4e2824506.jpg', '167db8e4e2824506.jpg');
INSERT INTO `t_sys_file_info` VALUES (244, NULL, NULL, NULL, NULL, '167dda42aea24507.jpg', '167dda42aea24507.jpg');
INSERT INTO `t_sys_file_info` VALUES (245, NULL, NULL, NULL, NULL, '167ddb8688c24511.jpg', '167ddb8688c24511.jpg');
INSERT INTO `t_sys_file_info` VALUES (246, NULL, NULL, NULL, NULL, '167de0a962d24525.jpg', '167de0a962d24525.jpg');
INSERT INTO `t_sys_file_info` VALUES (247, NULL, NULL, NULL, NULL, '167df2f999824551.png', '167df2f999824551.png');
INSERT INTO `t_sys_file_info` VALUES (248, NULL, NULL, NULL, NULL, '167df30223524552.png', '167df30223524552.png');
INSERT INTO `t_sys_file_info` VALUES (249, NULL, NULL, NULL, NULL, '167df697cf524556.jpg', '167df697cf524556.jpg');
INSERT INTO `t_sys_file_info` VALUES (250, NULL, NULL, NULL, NULL, '167df6fd43324558.jpg', '167df6fd43324558.jpg');
INSERT INTO `t_sys_file_info` VALUES (251, NULL, NULL, NULL, NULL, '167dff6695924563.png', '167dff6695924563.png');
INSERT INTO `t_sys_file_info` VALUES (252, NULL, NULL, NULL, NULL, '167dff789be24564.jpg', '167dff789be24564.jpg');
INSERT INTO `t_sys_file_info` VALUES (253, NULL, NULL, NULL, NULL, '167e00099e624566.jpg', '167e00099e624566.jpg');
INSERT INTO `t_sys_file_info` VALUES (254, NULL, NULL, NULL, NULL, '167e002934c24568.jpg', '167e002934c24568.jpg');
INSERT INTO `t_sys_file_info` VALUES (255, NULL, NULL, NULL, NULL, '167e05db0f724569.jpg', '167e05db0f724569.jpg');
INSERT INTO `t_sys_file_info` VALUES (256, NULL, NULL, NULL, NULL, '167e05e8b7024572.jpg', '167e05e8b7024572.jpg');
INSERT INTO `t_sys_file_info` VALUES (257, NULL, NULL, NULL, NULL, '167e0754b2b24573.jpg', '167e0754b2b24573.jpg');
INSERT INTO `t_sys_file_info` VALUES (258, NULL, NULL, NULL, NULL, '167e0866f5124575.jpg', '167e0866f5124575.jpg');
INSERT INTO `t_sys_file_info` VALUES (259, NULL, NULL, NULL, NULL, '167e087552324576.jpg', '167e087552324576.jpg');
INSERT INTO `t_sys_file_info` VALUES (260, NULL, NULL, NULL, NULL, '167e2e3023824580.jpg', '167e2e3023824580.jpg');
INSERT INTO `t_sys_file_info` VALUES (261, NULL, NULL, NULL, NULL, '167e32a07dc24594.jpg', '167e32a07dc24594.jpg');
INSERT INTO `t_sys_file_info` VALUES (262, NULL, NULL, NULL, NULL, '167e343f72624606.jpg', '167e343f72624606.jpg');
INSERT INTO `t_sys_file_info` VALUES (263, NULL, NULL, NULL, NULL, '167e42133a524639.jpg', '167e42133a524639.jpg');
INSERT INTO `t_sys_file_info` VALUES (264, NULL, NULL, NULL, NULL, '167e4265a4024642.jpg', '167e4265a4024642.jpg');
INSERT INTO `t_sys_file_info` VALUES (265, NULL, NULL, NULL, NULL, '167e433d84824648.jpg', '167e433d84824648.jpg');
INSERT INTO `t_sys_file_info` VALUES (266, NULL, NULL, NULL, NULL, '167e44e027824654.png', '167e44e027824654.png');
INSERT INTO `t_sys_file_info` VALUES (267, NULL, NULL, NULL, NULL, '167e45c2ab824657.jpg', '167e45c2ab824657.jpg');
INSERT INTO `t_sys_file_info` VALUES (268, NULL, NULL, NULL, NULL, '167e463dca824662.jpg', '167e463dca824662.jpg');
INSERT INTO `t_sys_file_info` VALUES (269, NULL, NULL, NULL, NULL, '167e47f802324667.jpg', '167e47f802324667.jpg');
INSERT INTO `t_sys_file_info` VALUES (270, NULL, NULL, NULL, NULL, '167e4e4528924693.jpg', '167e4e4528924693.jpg');
INSERT INTO `t_sys_file_info` VALUES (271, NULL, NULL, NULL, NULL, '167e611fa8724705.png', '167e611fa8724705.png');
INSERT INTO `t_sys_file_info` VALUES (272, NULL, NULL, NULL, NULL, '167e616587624706.png', '167e616587624706.png');
INSERT INTO `t_sys_file_info` VALUES (273, NULL, NULL, NULL, NULL, '167e61c03c724707.png', '167e61c03c724707.png');
INSERT INTO `t_sys_file_info` VALUES (274, NULL, NULL, NULL, NULL, '167e6433c1824708.png', '167e6433c1824708.png');
INSERT INTO `t_sys_file_info` VALUES (275, NULL, NULL, NULL, NULL, '167e88823c024733.jpg', '167e88823c024733.jpg');
INSERT INTO `t_sys_file_info` VALUES (276, NULL, NULL, NULL, NULL, '167e8d6838624734.png', '167e8d6838624734.png');
INSERT INTO `t_sys_file_info` VALUES (277, NULL, NULL, NULL, NULL, '167e8f5c43624736.png', '167e8f5c43624736.png');
INSERT INTO `t_sys_file_info` VALUES (278, NULL, NULL, NULL, NULL, '167e92dd27324744.jpg', '167e92dd27324744.jpg');
INSERT INTO `t_sys_file_info` VALUES (279, NULL, NULL, NULL, NULL, '167e9523a4d24754.png', '167e9523a4d24754.png');
INSERT INTO `t_sys_file_info` VALUES (280, NULL, NULL, NULL, NULL, '167e9af6a5824795.jpg', '167e9af6a5824795.jpg');
INSERT INTO `t_sys_file_info` VALUES (281, NULL, NULL, NULL, NULL, '167e9b02f8124798.jpg', '167e9b02f8124798.jpg');
INSERT INTO `t_sys_file_info` VALUES (282, NULL, NULL, NULL, NULL, '167e9b16c7b24803.jpg', '167e9b16c7b24803.jpg');
INSERT INTO `t_sys_file_info` VALUES (283, NULL, NULL, NULL, NULL, '167e9b2137e24805.jpg', '167e9b2137e24805.jpg');
INSERT INTO `t_sys_file_info` VALUES (284, NULL, NULL, NULL, NULL, '167e9bd790d24809.jpg', '167e9bd790d24809.jpg');
INSERT INTO `t_sys_file_info` VALUES (285, NULL, NULL, NULL, NULL, '167e9bdd13324810.jpg', '167e9bdd13324810.jpg');
INSERT INTO `t_sys_file_info` VALUES (286, NULL, NULL, NULL, NULL, '167e9e84c1f24822.png', '167e9e84c1f24822.png');
INSERT INTO `t_sys_file_info` VALUES (287, NULL, NULL, NULL, NULL, '167e9eb391324823.png', '167e9eb391324823.png');
INSERT INTO `t_sys_file_info` VALUES (288, NULL, NULL, NULL, NULL, '167ea105e3b24836.png', '167ea105e3b24836.png');
INSERT INTO `t_sys_file_info` VALUES (289, NULL, NULL, NULL, NULL, '167eab3906924842.jpg', '167eab3906924842.jpg');
INSERT INTO `t_sys_file_info` VALUES (290, NULL, NULL, NULL, NULL, '167ed7019f624869.jpg', '167ed7019f624869.jpg');
INSERT INTO `t_sys_file_info` VALUES (291, NULL, NULL, NULL, NULL, '167ed82c0a624880.jpg', '167ed82c0a624880.jpg');
INSERT INTO `t_sys_file_info` VALUES (292, NULL, NULL, NULL, NULL, '167ee0d5ca524892.jpg', '167ee0d5ca524892.jpg');
INSERT INTO `t_sys_file_info` VALUES (293, NULL, NULL, NULL, NULL, '167ee72c76224910.jpg', '167ee72c76224910.jpg');
INSERT INTO `t_sys_file_info` VALUES (294, NULL, NULL, NULL, NULL, '167eedeb7c624934.jpg', '167eedeb7c624934.jpg');
INSERT INTO `t_sys_file_info` VALUES (295, NULL, NULL, NULL, NULL, '167eee4c0e524936.png', '167eee4c0e524936.png');
INSERT INTO `t_sys_file_info` VALUES (296, NULL, NULL, NULL, NULL, '167eee5c94a24937.png', '167eee5c94a24937.png');
INSERT INTO `t_sys_file_info` VALUES (297, NULL, NULL, NULL, NULL, '167ef08729724945.png', '167ef08729724945.png');
INSERT INTO `t_sys_file_info` VALUES (298, NULL, NULL, NULL, NULL, '1681f9d6af225082.jpg', '1681f9d6af225082.jpg');
INSERT INTO `t_sys_file_info` VALUES (299, NULL, NULL, NULL, NULL, '168217f7dea25088.jpg', '168217f7dea25088.jpg');
INSERT INTO `t_sys_file_info` VALUES (300, NULL, NULL, NULL, NULL, '168275a14fd25116.png', '168275a14fd25116.png');
INSERT INTO `t_sys_file_info` VALUES (301, NULL, NULL, NULL, NULL, '1682b131ee025168.jpg', '1682b131ee025168.jpg');
INSERT INTO `t_sys_file_info` VALUES (302, NULL, NULL, NULL, NULL, '1682b14414625171.jpeg', '1682b14414625171.jpeg');
INSERT INTO `t_sys_file_info` VALUES (303, NULL, NULL, NULL, NULL, '1682c73df6725223.png', '1682c73df6725223.png');
INSERT INTO `t_sys_file_info` VALUES (304, NULL, NULL, NULL, NULL, '1682c9d901525235.jpg', '1682c9d901525235.jpg');
INSERT INTO `t_sys_file_info` VALUES (305, NULL, NULL, NULL, NULL, '1682d26be7425243.jpg', '1682d26be7425243.jpg');
INSERT INTO `t_sys_file_info` VALUES (306, NULL, NULL, NULL, NULL, '1682d56f1f325248.png', '1682d56f1f325248.png');
INSERT INTO `t_sys_file_info` VALUES (307, NULL, NULL, NULL, NULL, '1682dfd656625253.jpg', '1682dfd656625253.jpg');
INSERT INTO `t_sys_file_info` VALUES (308, NULL, NULL, NULL, NULL, '16830aeb08625266.jpg', '16830aeb08625266.jpg');
INSERT INTO `t_sys_file_info` VALUES (309, NULL, NULL, NULL, NULL, '1683180d74325278.png', '1683180d74325278.png');
INSERT INTO `t_sys_file_info` VALUES (310, NULL, NULL, NULL, NULL, '1683185b1d125284.jpg', '1683185b1d125284.jpg');
INSERT INTO `t_sys_file_info` VALUES (311, NULL, NULL, NULL, NULL, '1683186998e25285.png', '1683186998e25285.png');
INSERT INTO `t_sys_file_info` VALUES (312, NULL, NULL, NULL, NULL, '16831b0857825292.png', '16831b0857825292.png');
INSERT INTO `t_sys_file_info` VALUES (313, NULL, NULL, NULL, NULL, '16831f4f56f25298.jpg', '16831f4f56f25298.jpg');
INSERT INTO `t_sys_file_info` VALUES (314, NULL, NULL, NULL, NULL, '16831f7eda025299.jpg', '16831f7eda025299.jpg');
INSERT INTO `t_sys_file_info` VALUES (315, NULL, NULL, NULL, NULL, '1683203e76025306.jpg', '1683203e76025306.jpg');
INSERT INTO `t_sys_file_info` VALUES (316, NULL, NULL, NULL, NULL, '1683205267325307.jpg', '1683205267325307.jpg');
INSERT INTO `t_sys_file_info` VALUES (317, NULL, NULL, NULL, NULL, '16836da7af925357.jpg', '16836da7af925357.jpg');
INSERT INTO `t_sys_file_info` VALUES (318, NULL, NULL, NULL, NULL, '168370bc58a25365.jpg', '168370bc58a25365.jpg');
INSERT INTO `t_sys_file_info` VALUES (319, NULL, NULL, NULL, NULL, '16837fc961525374.png', '16837fc961525374.png');
INSERT INTO `t_sys_file_info` VALUES (320, NULL, NULL, NULL, NULL, '1683af7cf9125386.png', '1683af7cf9125386.png');
INSERT INTO `t_sys_file_info` VALUES (321, NULL, NULL, NULL, NULL, '1683b5d942525390.png', '1683b5d942525390.png');
INSERT INTO `t_sys_file_info` VALUES (322, NULL, NULL, NULL, NULL, '1683bab366625396.jpg', '1683bab366625396.jpg');
INSERT INTO `t_sys_file_info` VALUES (323, NULL, NULL, NULL, NULL, '1683bb1081425403.png', '1683bb1081425403.png');
INSERT INTO `t_sys_file_info` VALUES (324, NULL, NULL, NULL, NULL, '168412e27cf25452.jpg', '168412e27cf25452.jpg');
INSERT INTO `t_sys_file_info` VALUES (325, NULL, NULL, NULL, NULL, '168416fcd6b25453.png', '168416fcd6b25453.png');
INSERT INTO `t_sys_file_info` VALUES (326, NULL, NULL, NULL, NULL, '16841853ff725454.jpg', '16841853ff725454.jpg');
INSERT INTO `t_sys_file_info` VALUES (327, NULL, NULL, NULL, NULL, '1684220ac2625455.jpg', '1684220ac2625455.jpg');
INSERT INTO `t_sys_file_info` VALUES (328, NULL, NULL, NULL, NULL, '168429d617425463.jpg', '168429d617425463.jpg');
INSERT INTO `t_sys_file_info` VALUES (329, NULL, NULL, NULL, NULL, '168429e015f25466.jpg', '168429e015f25466.jpg');
INSERT INTO `t_sys_file_info` VALUES (330, NULL, NULL, NULL, NULL, '16845dc7a7025473.png', '16845dc7a7025473.png');
INSERT INTO `t_sys_file_info` VALUES (331, NULL, NULL, NULL, NULL, '16846b2e9fe25481.jpg', '16846b2e9fe25481.jpg');
INSERT INTO `t_sys_file_info` VALUES (332, NULL, NULL, NULL, NULL, '16846b39e7125484.jpg', '16846b39e7125484.jpg');
INSERT INTO `t_sys_file_info` VALUES (333, NULL, NULL, NULL, NULL, '1684728ed9525486.png', '1684728ed9525486.png');
INSERT INTO `t_sys_file_info` VALUES (334, NULL, NULL, NULL, NULL, '1684730298525487.jpg', '1684730298525487.jpg');
INSERT INTO `t_sys_file_info` VALUES (335, NULL, NULL, NULL, NULL, '168473ead8e25488.png', '168473ead8e25488.png');
INSERT INTO `t_sys_file_info` VALUES (336, NULL, NULL, NULL, NULL, '16849a7e13d25490.png', '16849a7e13d25490.png');
INSERT INTO `t_sys_file_info` VALUES (337, NULL, NULL, NULL, NULL, '16849e954c225491.jpg', '16849e954c225491.jpg');
INSERT INTO `t_sys_file_info` VALUES (338, NULL, NULL, NULL, NULL, '16849fd334a25492.jpg', '16849fd334a25492.jpg');
INSERT INTO `t_sys_file_info` VALUES (339, NULL, NULL, NULL, NULL, '1684a12fe0625493.png', '1684a12fe0625493.png');
INSERT INTO `t_sys_file_info` VALUES (340, NULL, NULL, NULL, NULL, '1684a13a41025494.png', '1684a13a41025494.png');
INSERT INTO `t_sys_file_info` VALUES (341, NULL, NULL, NULL, NULL, '1684a4b51ee25499.png', '1684a4b51ee25499.png');
INSERT INTO `t_sys_file_info` VALUES (342, NULL, NULL, NULL, NULL, '1684a73348c25512.png', '1684a73348c25512.png');
INSERT INTO `t_sys_file_info` VALUES (343, NULL, NULL, NULL, NULL, '1684ae4781225514.jpg', '1684ae4781225514.jpg');
INSERT INTO `t_sys_file_info` VALUES (344, NULL, NULL, NULL, NULL, '1684af7cf7425516.jpg', '1684af7cf7425516.jpg');
INSERT INTO `t_sys_file_info` VALUES (345, NULL, NULL, NULL, NULL, '1684b5c5be125533.png', '1684b5c5be125533.png');
INSERT INTO `t_sys_file_info` VALUES (346, NULL, NULL, NULL, NULL, '1684b5d8cb625536.png', '1684b5d8cb625536.png');
INSERT INTO `t_sys_file_info` VALUES (347, NULL, NULL, NULL, NULL, '1684b5ef5c325537.png', '1684b5ef5c325537.png');
INSERT INTO `t_sys_file_info` VALUES (348, NULL, NULL, NULL, NULL, '1684b65266725539.png', '1684b65266725539.png');
INSERT INTO `t_sys_file_info` VALUES (349, NULL, NULL, NULL, NULL, '1684b67f58925541.png', '1684b67f58925541.png');
INSERT INTO `t_sys_file_info` VALUES (350, NULL, NULL, NULL, NULL, '1684bee173f25549.jpg', '1684bee173f25549.jpg');
INSERT INTO `t_sys_file_info` VALUES (351, NULL, NULL, NULL, NULL, '1684f35edb325603.jpg', '1684f35edb325603.jpg');
INSERT INTO `t_sys_file_info` VALUES (352, NULL, NULL, NULL, NULL, '1684f6472af25610.jpg', '1684f6472af25610.jpg');
INSERT INTO `t_sys_file_info` VALUES (353, NULL, NULL, NULL, NULL, '1684f839f9e25617.png', '1684f839f9e25617.png');
INSERT INTO `t_sys_file_info` VALUES (354, NULL, NULL, NULL, NULL, '1685020480025625.jpg', '1685020480025625.jpg');
INSERT INTO `t_sys_file_info` VALUES (355, NULL, NULL, NULL, NULL, '1685021072025626.jpg', '1685021072025626.jpg');
INSERT INTO `t_sys_file_info` VALUES (356, NULL, NULL, NULL, NULL, '168502407ea25627.png', '168502407ea25627.png');
INSERT INTO `t_sys_file_info` VALUES (357, NULL, NULL, NULL, NULL, '168502fc4eb25631.jpg', '168502fc4eb25631.jpg');
INSERT INTO `t_sys_file_info` VALUES (358, NULL, NULL, NULL, NULL, '16850680a1f25647.jpg', '16850680a1f25647.jpg');
INSERT INTO `t_sys_file_info` VALUES (359, NULL, NULL, NULL, NULL, '1685087b00625651.jpg', '1685087b00625651.jpg');
INSERT INTO `t_sys_file_info` VALUES (360, NULL, NULL, NULL, NULL, '16850b9eccf25658.png', '16850b9eccf25658.png');
INSERT INTO `t_sys_file_info` VALUES (361, NULL, NULL, NULL, NULL, '16850cb1a1425663.jpg', '16850cb1a1425663.jpg');
INSERT INTO `t_sys_file_info` VALUES (362, NULL, NULL, NULL, NULL, '16850cbc61e25666.jpg', '16850cbc61e25666.jpg');
INSERT INTO `t_sys_file_info` VALUES (363, NULL, NULL, NULL, NULL, '168511ad8a025671.jpg', '168511ad8a025671.jpg');
INSERT INTO `t_sys_file_info` VALUES (364, NULL, NULL, NULL, NULL, '168517acc9425673.png', '168517acc9425673.png');
INSERT INTO `t_sys_file_info` VALUES (365, NULL, NULL, NULL, NULL, '168519fa70225674.jpg', '168519fa70225674.jpg');
INSERT INTO `t_sys_file_info` VALUES (366, NULL, NULL, NULL, NULL, '16854a021da25689.png', '16854a021da25689.png');
INSERT INTO `t_sys_file_info` VALUES (367, NULL, NULL, NULL, NULL, '16854c03bb825692.png', '16854c03bb825692.png');
INSERT INTO `t_sys_file_info` VALUES (368, NULL, NULL, NULL, NULL, '16854ea5e3725695.jpg', '16854ea5e3725695.jpg');
INSERT INTO `t_sys_file_info` VALUES (369, NULL, NULL, NULL, NULL, '168552cdb8925696.png', '168552cdb8925696.png');
INSERT INTO `t_sys_file_info` VALUES (370, NULL, NULL, NULL, NULL, '1685537be4825697.jpg', '1685537be4825697.jpg');
INSERT INTO `t_sys_file_info` VALUES (371, NULL, NULL, NULL, NULL, '168553910dd25698.jpg', '168553910dd25698.jpg');
INSERT INTO `t_sys_file_info` VALUES (372, NULL, NULL, NULL, NULL, '168559a706325701.jpg', '168559a706325701.jpg');
INSERT INTO `t_sys_file_info` VALUES (373, NULL, NULL, NULL, NULL, '16855d3270825703.jpg', '16855d3270825703.jpg');
INSERT INTO `t_sys_file_info` VALUES (374, NULL, NULL, NULL, NULL, '16855d43c5e25704.jpg', '16855d43c5e25704.jpg');
INSERT INTO `t_sys_file_info` VALUES (375, NULL, NULL, NULL, NULL, '16855e2cefe25709.png', '16855e2cefe25709.png');
INSERT INTO `t_sys_file_info` VALUES (376, NULL, NULL, NULL, NULL, '1685610fd5f25720.png', '1685610fd5f25720.png');
INSERT INTO `t_sys_file_info` VALUES (377, NULL, NULL, NULL, NULL, '1685992e0f425731.png', '1685992e0f425731.png');
INSERT INTO `t_sys_file_info` VALUES (378, NULL, NULL, NULL, NULL, '1685994800725732.png', '1685994800725732.png');
INSERT INTO `t_sys_file_info` VALUES (379, NULL, NULL, NULL, NULL, '1685996459f25735.png', '1685996459f25735.png');
INSERT INTO `t_sys_file_info` VALUES (380, NULL, NULL, NULL, NULL, '16859f1290d25748.jpg', '16859f1290d25748.jpg');
INSERT INTO `t_sys_file_info` VALUES (381, NULL, NULL, NULL, NULL, '1685a1ebc6425749.png', '1685a1ebc6425749.png');
INSERT INTO `t_sys_file_info` VALUES (382, NULL, NULL, NULL, NULL, '1685a60254c25751.jpg', '1685a60254c25751.jpg');
INSERT INTO `t_sys_file_info` VALUES (383, NULL, NULL, NULL, NULL, '1685a63350c25754.jpg', '1685a63350c25754.jpg');
INSERT INTO `t_sys_file_info` VALUES (384, NULL, NULL, NULL, NULL, '1685a852fdc25763.jpeg', '1685a852fdc25763.jpeg');
INSERT INTO `t_sys_file_info` VALUES (385, NULL, NULL, NULL, NULL, '1685a8d8e3f25771.jpg', '1685a8d8e3f25771.jpg');
INSERT INTO `t_sys_file_info` VALUES (386, NULL, NULL, NULL, NULL, '1685adf996425810.jpeg', '1685adf996425810.jpeg');
INSERT INTO `t_sys_file_info` VALUES (387, NULL, NULL, NULL, NULL, '1685af4a8b425813.png', '1685af4a8b425813.png');
INSERT INTO `t_sys_file_info` VALUES (388, NULL, NULL, NULL, NULL, '1685b0f126925816.jpg', '1685b0f126925816.jpg');
INSERT INTO `t_sys_file_info` VALUES (389, NULL, NULL, NULL, NULL, '1685b11183925817.jpg', '1685b11183925817.jpg');
INSERT INTO `t_sys_file_info` VALUES (390, NULL, NULL, NULL, NULL, '1685ed3fae625851.jpg', '1685ed3fae625851.jpg');
INSERT INTO `t_sys_file_info` VALUES (391, NULL, NULL, NULL, NULL, '1685f6a035125860.jpg', '1685f6a035125860.jpg');
INSERT INTO `t_sys_file_info` VALUES (392, NULL, NULL, NULL, NULL, '1685fcb9ae525870.png', '1685fcb9ae525870.png');
INSERT INTO `t_sys_file_info` VALUES (393, NULL, NULL, NULL, NULL, '16862a8151725881.png', '16862a8151725881.png');
INSERT INTO `t_sys_file_info` VALUES (394, NULL, NULL, NULL, NULL, '16862a8aa7325882.jpg', '16862a8aa7325882.jpg');
INSERT INTO `t_sys_file_info` VALUES (395, NULL, NULL, NULL, NULL, '1686a46635525948.jpg', '1686a46635525948.jpg');
INSERT INTO `t_sys_file_info` VALUES (396, NULL, NULL, NULL, NULL, '1686beaf0ed25958.jpg', '1686beaf0ed25958.jpg');
INSERT INTO `t_sys_file_info` VALUES (397, NULL, NULL, NULL, NULL, '1686bef0eee25959.jpg', '1686bef0eee25959.jpg');
INSERT INTO `t_sys_file_info` VALUES (398, NULL, NULL, NULL, NULL, '1686bf4074e25960.jpg', '1686bf4074e25960.jpg');
INSERT INTO `t_sys_file_info` VALUES (399, NULL, NULL, NULL, NULL, '1686e432d9825975.png', '1686e432d9825975.png');
INSERT INTO `t_sys_file_info` VALUES (400, NULL, NULL, NULL, NULL, '1686e5a6b8525979.jpg', '1686e5a6b8525979.jpg');
INSERT INTO `t_sys_file_info` VALUES (401, NULL, NULL, NULL, NULL, '1686f32075125995.png', '1686f32075125995.png');
INSERT INTO `t_sys_file_info` VALUES (402, NULL, NULL, NULL, NULL, '1686f34251225996.png', '1686f34251225996.png');
INSERT INTO `t_sys_file_info` VALUES (403, NULL, NULL, NULL, NULL, '1686f5d4ab826008.png', '1686f5d4ab826008.png');
INSERT INTO `t_sys_file_info` VALUES (404, NULL, NULL, NULL, NULL, '1686f67dd5f26009.png', '1686f67dd5f26009.png');
INSERT INTO `t_sys_file_info` VALUES (405, NULL, NULL, NULL, NULL, '1686fc73e1c26020.jpg', '1686fc73e1c26020.jpg');
INSERT INTO `t_sys_file_info` VALUES (406, NULL, NULL, NULL, NULL, '1686fcd8d0926021.jpg', '1686fcd8d0926021.jpg');
INSERT INTO `t_sys_file_info` VALUES (407, NULL, NULL, NULL, NULL, '1686fcf16e526022.jpg', '1686fcf16e526022.jpg');
INSERT INTO `t_sys_file_info` VALUES (408, NULL, NULL, NULL, NULL, '1686fdcfa3226028.jpg', '1686fdcfa3226028.jpg');
INSERT INTO `t_sys_file_info` VALUES (409, NULL, NULL, NULL, NULL, '1686fdd618b26029.jpg', '1686fdd618b26029.jpg');
INSERT INTO `t_sys_file_info` VALUES (410, NULL, NULL, NULL, NULL, '168701d080226032.jpg', '168701d080226032.jpg');
INSERT INTO `t_sys_file_info` VALUES (411, NULL, NULL, NULL, NULL, '168734c05e026045.png', '168734c05e026045.png');
INSERT INTO `t_sys_file_info` VALUES (412, NULL, NULL, NULL, NULL, '16873960e4326052.jpeg', '16873960e4326052.jpeg');
INSERT INTO `t_sys_file_info` VALUES (413, NULL, NULL, NULL, NULL, '16873a7b6b226055.jpeg', '16873a7b6b226055.jpeg');
INSERT INTO `t_sys_file_info` VALUES (414, NULL, NULL, NULL, NULL, '1687448a3f126063.png', '1687448a3f126063.png');
INSERT INTO `t_sys_file_info` VALUES (415, NULL, NULL, NULL, NULL, '1687450b9c926073.jpg', '1687450b9c926073.jpg');
INSERT INTO `t_sys_file_info` VALUES (416, NULL, NULL, NULL, NULL, '1687467ad0a26075.jpg', '1687467ad0a26075.jpg');
INSERT INTO `t_sys_file_info` VALUES (417, NULL, NULL, NULL, NULL, '1687479efae26081.jpg', '1687479efae26081.jpg');
INSERT INTO `t_sys_file_info` VALUES (418, NULL, NULL, NULL, NULL, '16874aa902e26099.jpg', '16874aa902e26099.jpg');
INSERT INTO `t_sys_file_info` VALUES (419, NULL, NULL, NULL, NULL, '16874af024526103.jpg', '16874af024526103.jpg');
INSERT INTO `t_sys_file_info` VALUES (420, NULL, NULL, NULL, NULL, '168755a01e026115.jpg', '168755a01e026115.jpg');
INSERT INTO `t_sys_file_info` VALUES (421, NULL, NULL, NULL, NULL, '16875c37a9926118.jpg', '16875c37a9926118.jpg');
INSERT INTO `t_sys_file_info` VALUES (422, NULL, NULL, NULL, NULL, '168787b65af26131.jpg', '168787b65af26131.jpg');
INSERT INTO `t_sys_file_info` VALUES (423, NULL, NULL, NULL, NULL, '168788bbf8426135.jpg', '168788bbf8426135.jpg');
INSERT INTO `t_sys_file_info` VALUES (424, NULL, NULL, NULL, NULL, '1687937286626144.jpg', '1687937286626144.jpg');
INSERT INTO `t_sys_file_info` VALUES (425, NULL, NULL, NULL, NULL, '1687962ff0e26152.jpeg', '1687962ff0e26152.jpeg');
INSERT INTO `t_sys_file_info` VALUES (426, NULL, NULL, NULL, NULL, '1687991c0c426158.jpeg', '1687991c0c426158.jpeg');
INSERT INTO `t_sys_file_info` VALUES (427, NULL, NULL, NULL, NULL, '1687a9cda4d26192.png', '1687a9cda4d26192.png');
INSERT INTO `t_sys_file_info` VALUES (428, NULL, NULL, NULL, NULL, '1687aaa8d0626195.png', '1687aaa8d0626195.png');
INSERT INTO `t_sys_file_info` VALUES (429, NULL, NULL, NULL, NULL, '1687adc37cb26196.jpg', '1687adc37cb26196.jpg');
INSERT INTO `t_sys_file_info` VALUES (430, NULL, NULL, NULL, NULL, '1687ae9e53926199.jpg', '1687ae9e53926199.jpg');
INSERT INTO `t_sys_file_info` VALUES (431, NULL, NULL, NULL, NULL, '1687dcf976326216.jpg', '1687dcf976326216.jpg');
INSERT INTO `t_sys_file_info` VALUES (432, NULL, NULL, NULL, NULL, '1687de7a0bb26217.png', '1687de7a0bb26217.png');
INSERT INTO `t_sys_file_info` VALUES (433, NULL, NULL, NULL, NULL, '1687e15d22826225.png', '1687e15d22826225.png');
INSERT INTO `t_sys_file_info` VALUES (434, NULL, NULL, NULL, NULL, '1687e54f3eb26229.jpg', '1687e54f3eb26229.jpg');
INSERT INTO `t_sys_file_info` VALUES (435, NULL, NULL, NULL, NULL, '1687ec1251a26249.jpg', '1687ec1251a26249.jpg');
INSERT INTO `t_sys_file_info` VALUES (436, NULL, NULL, NULL, NULL, '1687ec68dff26252.jpg', '1687ec68dff26252.jpg');
INSERT INTO `t_sys_file_info` VALUES (437, NULL, NULL, NULL, NULL, '1687ee2216926257.png', '1687ee2216926257.png');
INSERT INTO `t_sys_file_info` VALUES (438, NULL, NULL, NULL, NULL, '1687ee5cb2526258.jpg', '1687ee5cb2526258.jpg');
INSERT INTO `t_sys_file_info` VALUES (439, NULL, NULL, NULL, NULL, '1687eed0b5726260.jpg', '1687eed0b5726260.jpg');
INSERT INTO `t_sys_file_info` VALUES (440, NULL, NULL, NULL, NULL, '1687ef2c80526261.jpg', '1687ef2c80526261.jpg');
INSERT INTO `t_sys_file_info` VALUES (441, NULL, NULL, NULL, NULL, '1687f3b76d626268.jpg', '1687f3b76d626268.jpg');
INSERT INTO `t_sys_file_info` VALUES (442, NULL, NULL, NULL, NULL, '1687f64f61726272.jpg', '1687f64f61726272.jpg');
INSERT INTO `t_sys_file_info` VALUES (443, NULL, NULL, NULL, NULL, '1687f669f3126275.jpg', '1687f669f3126275.jpg');
INSERT INTO `t_sys_file_info` VALUES (444, NULL, NULL, NULL, NULL, '1687f715e6f26280.jpg', '1687f715e6f26280.jpg');
INSERT INTO `t_sys_file_info` VALUES (445, NULL, NULL, NULL, NULL, '168800e0e7626286.jpg', '168800e0e7626286.jpg');
INSERT INTO `t_sys_file_info` VALUES (446, NULL, NULL, NULL, NULL, '1688382937226303.png', '1688382937226303.png');
INSERT INTO `t_sys_file_info` VALUES (447, NULL, NULL, NULL, NULL, '16883ca660d26308.jpg', '16883ca660d26308.jpg');
INSERT INTO `t_sys_file_info` VALUES (448, NULL, NULL, NULL, NULL, '16883d43f2026312.jpeg', '16883d43f2026312.jpeg');
INSERT INTO `t_sys_file_info` VALUES (449, NULL, NULL, NULL, NULL, '16883d8039526315.png', '16883d8039526315.png');
INSERT INTO `t_sys_file_info` VALUES (450, NULL, NULL, NULL, NULL, '16883daac1526316.png', '16883daac1526316.png');
INSERT INTO `t_sys_file_info` VALUES (451, NULL, NULL, NULL, NULL, '16883dba3fc26319.png', '16883dba3fc26319.png');
INSERT INTO `t_sys_file_info` VALUES (452, NULL, NULL, NULL, NULL, '16883f6a59326343.jpg', '16883f6a59326343.jpg');
INSERT INTO `t_sys_file_info` VALUES (453, NULL, NULL, NULL, NULL, '16883fbdb6426346.jpg', '16883fbdb6426346.jpg');
INSERT INTO `t_sys_file_info` VALUES (454, NULL, NULL, NULL, NULL, '1688402363b26347.jpg', '1688402363b26347.jpg');
INSERT INTO `t_sys_file_info` VALUES (455, NULL, NULL, NULL, NULL, '1688403d16926348.jpg', '1688403d16926348.jpg');
INSERT INTO `t_sys_file_info` VALUES (456, NULL, NULL, NULL, NULL, '16888ff078c26402.jpg', '16888ff078c26402.jpg');
INSERT INTO `t_sys_file_info` VALUES (457, NULL, NULL, NULL, NULL, '1688999ff0b26408.jpg', '1688999ff0b26408.jpg');
INSERT INTO `t_sys_file_info` VALUES (458, NULL, NULL, NULL, NULL, '1688e0f570626409.jpg', '1688e0f570626409.jpg');
INSERT INTO `t_sys_file_info` VALUES (459, NULL, NULL, NULL, NULL, '1688ef7ffde26410.jpg', '1688ef7ffde26410.jpg');
INSERT INTO `t_sys_file_info` VALUES (460, NULL, NULL, NULL, NULL, '1688ef9081026411.jpg', '1688ef9081026411.jpg');
INSERT INTO `t_sys_file_info` VALUES (461, NULL, NULL, NULL, NULL, '1688efa9cb226412.jpg', '1688efa9cb226412.jpg');
INSERT INTO `t_sys_file_info` VALUES (462, NULL, NULL, NULL, NULL, '1688efc611a26413.jpg', '1688efc611a26413.jpg');
INSERT INTO `t_sys_file_info` VALUES (463, NULL, NULL, NULL, NULL, '1689079cc0426417.jpg', '1689079cc0426417.jpg');
INSERT INTO `t_sys_file_info` VALUES (464, NULL, NULL, NULL, NULL, '16891fa730026420.jpg', '16891fa730026420.jpg');
INSERT INTO `t_sys_file_info` VALUES (465, NULL, NULL, NULL, NULL, '168939e42c526443.jpg', '168939e42c526443.jpg');
INSERT INTO `t_sys_file_info` VALUES (466, NULL, NULL, NULL, NULL, '16894baec1d26474.jpg', '16894baec1d26474.jpg');
INSERT INTO `t_sys_file_info` VALUES (467, NULL, NULL, NULL, NULL, '168978c1e6f26491.jpg', '168978c1e6f26491.jpg');
INSERT INTO `t_sys_file_info` VALUES (468, NULL, NULL, NULL, NULL, '168978fccc326493.jpg', '168978fccc326493.jpg');
INSERT INTO `t_sys_file_info` VALUES (469, NULL, NULL, NULL, NULL, '16897a9ad2c26498.png', '16897a9ad2c26498.png');
INSERT INTO `t_sys_file_info` VALUES (470, NULL, NULL, NULL, NULL, '1689850987e26503.png', '1689850987e26503.png');
INSERT INTO `t_sys_file_info` VALUES (471, NULL, NULL, NULL, NULL, '1689870e66e26510.jpg', '1689870e66e26510.jpg');
INSERT INTO `t_sys_file_info` VALUES (472, NULL, NULL, NULL, NULL, '168987f098926517.png', '168987f098926517.png');
INSERT INTO `t_sys_file_info` VALUES (473, NULL, NULL, NULL, NULL, '1689882ad5926519.png', '1689882ad5926519.png');
INSERT INTO `t_sys_file_info` VALUES (474, NULL, NULL, NULL, NULL, '168988d167426521.jpg', '168988d167426521.jpg');
INSERT INTO `t_sys_file_info` VALUES (475, NULL, NULL, NULL, NULL, '16898abf6a826522.png', '16898abf6a826522.png');
INSERT INTO `t_sys_file_info` VALUES (476, NULL, NULL, NULL, NULL, '16898cd0f8f26529.jpeg', '16898cd0f8f26529.jpeg');
INSERT INTO `t_sys_file_info` VALUES (477, NULL, NULL, NULL, NULL, '16898e0bbd026531.jpg', '16898e0bbd026531.jpg');
INSERT INTO `t_sys_file_info` VALUES (478, NULL, NULL, NULL, NULL, '16898e3d31426534.jpg', '16898e3d31426534.jpg');
INSERT INTO `t_sys_file_info` VALUES (479, NULL, NULL, NULL, NULL, '16898ef5a9726535.jpeg', '16898ef5a9726535.jpeg');
INSERT INTO `t_sys_file_info` VALUES (480, NULL, NULL, NULL, NULL, '16898f5e55826537.jpeg', '16898f5e55826537.jpeg');
INSERT INTO `t_sys_file_info` VALUES (481, NULL, NULL, NULL, NULL, '168997601cc26542.png', '168997601cc26542.png');
INSERT INTO `t_sys_file_info` VALUES (482, NULL, NULL, NULL, NULL, '1689c53afa426552.jpg', '1689c53afa426552.jpg');
INSERT INTO `t_sys_file_info` VALUES (483, NULL, NULL, NULL, NULL, '1689c9f0bf926557.jpg', '1689c9f0bf926557.jpg');
INSERT INTO `t_sys_file_info` VALUES (484, NULL, NULL, NULL, NULL, '1689cac37b126559.jpg', '1689cac37b126559.jpg');
INSERT INTO `t_sys_file_info` VALUES (485, NULL, NULL, NULL, NULL, '1689d11694326575.jpg', '1689d11694326575.jpg');
INSERT INTO `t_sys_file_info` VALUES (486, NULL, NULL, NULL, NULL, '1689d2c8a4e26576.png', '1689d2c8a4e26576.png');
INSERT INTO `t_sys_file_info` VALUES (487, NULL, NULL, NULL, NULL, '1689d2cd04526577.png', '1689d2cd04526577.png');
INSERT INTO `t_sys_file_info` VALUES (488, NULL, NULL, NULL, NULL, '1689d2f860926578.png', '1689d2f860926578.png');
INSERT INTO `t_sys_file_info` VALUES (489, NULL, NULL, NULL, NULL, '1689dace60b26581.png', '1689dace60b26581.png');
INSERT INTO `t_sys_file_info` VALUES (490, NULL, NULL, NULL, NULL, '1689db8790b26582.png', '1689db8790b26582.png');
INSERT INTO `t_sys_file_info` VALUES (491, NULL, NULL, NULL, NULL, '1689dc2579626583.png', '1689dc2579626583.png');
INSERT INTO `t_sys_file_info` VALUES (492, NULL, NULL, NULL, NULL, '1689dcfa83926587.jpg', '1689dcfa83926587.jpg');
INSERT INTO `t_sys_file_info` VALUES (493, NULL, NULL, NULL, NULL, '1689dd4510826590.png', '1689dd4510826590.png');
INSERT INTO `t_sys_file_info` VALUES (494, NULL, NULL, NULL, NULL, '1689def47d426591.jpg', '1689def47d426591.jpg');
INSERT INTO `t_sys_file_info` VALUES (495, NULL, NULL, NULL, NULL, '1689e23413f26594.jpg', '1689e23413f26594.jpg');
INSERT INTO `t_sys_file_info` VALUES (496, NULL, NULL, NULL, NULL, '1689eacb7ad26597.png', '1689eacb7ad26597.png');
INSERT INTO `t_sys_file_info` VALUES (497, NULL, NULL, NULL, NULL, '1689eadc9d226600.jpg', '1689eadc9d226600.jpg');
INSERT INTO `t_sys_file_info` VALUES (498, NULL, NULL, NULL, NULL, '1689eb27eba26601.jpg', '1689eb27eba26601.jpg');
INSERT INTO `t_sys_file_info` VALUES (499, NULL, NULL, NULL, NULL, '1689eb68ca826604.jpg', '1689eb68ca826604.jpg');
INSERT INTO `t_sys_file_info` VALUES (500, NULL, NULL, NULL, NULL, '168a20ea71326621.jpg', '168a20ea71326621.jpg');
INSERT INTO `t_sys_file_info` VALUES (501, NULL, NULL, NULL, NULL, '168a2901bf426634.png', '168a2901bf426634.png');
INSERT INTO `t_sys_file_info` VALUES (502, NULL, NULL, NULL, NULL, '168a291e42e26635.png', '168a291e42e26635.png');
INSERT INTO `t_sys_file_info` VALUES (503, NULL, NULL, NULL, NULL, '168a292e60c26636.png', '168a292e60c26636.png');
INSERT INTO `t_sys_file_info` VALUES (504, NULL, NULL, NULL, NULL, '168a304411426643.png', '168a304411426643.png');
INSERT INTO `t_sys_file_info` VALUES (505, NULL, NULL, NULL, NULL, '168a3302ac826649.png', '168a3302ac826649.png');
INSERT INTO `t_sys_file_info` VALUES (506, NULL, NULL, NULL, NULL, '168a330fc7826650.png', '168a330fc7826650.png');
INSERT INTO `t_sys_file_info` VALUES (507, NULL, NULL, NULL, NULL, '168a3ad49e526654.jpg', '168a3ad49e526654.jpg');
INSERT INTO `t_sys_file_info` VALUES (508, NULL, NULL, NULL, NULL, '168a3adc92926655.jpg', '168a3adc92926655.jpg');
INSERT INTO `t_sys_file_info` VALUES (509, NULL, NULL, NULL, NULL, '168a816080c26672.png', '168a816080c26672.png');
INSERT INTO `t_sys_file_info` VALUES (510, NULL, NULL, NULL, NULL, '168ac0357f426675.png', '168ac0357f426675.png');
INSERT INTO `t_sys_file_info` VALUES (511, NULL, NULL, NULL, NULL, '168acb4184826680.jpg', '168acb4184826680.jpg');
INSERT INTO `t_sys_file_info` VALUES (512, NULL, NULL, NULL, NULL, '168ae11208226686.jpg', '168ae11208226686.jpg');
INSERT INTO `t_sys_file_info` VALUES (513, NULL, NULL, NULL, NULL, '168ae61c9b126687.jpg', '168ae61c9b126687.jpg');
INSERT INTO `t_sys_file_info` VALUES (514, NULL, NULL, NULL, NULL, '168b10aaaa526691.jpg', '168b10aaaa526691.jpg');
INSERT INTO `t_sys_file_info` VALUES (515, NULL, NULL, NULL, NULL, '168cb0673cf26708.jpg', '168cb0673cf26708.jpg');
INSERT INTO `t_sys_file_info` VALUES (516, NULL, NULL, NULL, NULL, '168cb104a4726709.png', '168cb104a4726709.png');
INSERT INTO `t_sys_file_info` VALUES (517, NULL, NULL, NULL, NULL, '168da3d25cd26721.jpg', '168da3d25cd26721.jpg');
INSERT INTO `t_sys_file_info` VALUES (518, NULL, NULL, NULL, NULL, '168dba5f4e426739.jpg', '168dba5f4e426739.jpg');
INSERT INTO `t_sys_file_info` VALUES (519, NULL, NULL, NULL, NULL, '168dc3036ab26745.jpg', '168dc3036ab26745.jpg');
INSERT INTO `t_sys_file_info` VALUES (520, NULL, NULL, NULL, NULL, '168dfd263e826759.png', '168dfd263e826759.png');
INSERT INTO `t_sys_file_info` VALUES (521, NULL, NULL, NULL, NULL, '168e05ee5b326764.png', '168e05ee5b326764.png');
INSERT INTO `t_sys_file_info` VALUES (522, NULL, NULL, NULL, NULL, '168e067bc9426767.jpg', '168e067bc9426767.jpg');
INSERT INTO `t_sys_file_info` VALUES (523, NULL, NULL, NULL, NULL, '168e0a63e6a26771.jpg', '168e0a63e6a26771.jpg');
INSERT INTO `t_sys_file_info` VALUES (524, NULL, NULL, NULL, NULL, '168e0ac6d4126775.png', '168e0ac6d4126775.png');
INSERT INTO `t_sys_file_info` VALUES (525, NULL, NULL, NULL, NULL, '168e0c5f0fa26776.png', '168e0c5f0fa26776.png');
INSERT INTO `t_sys_file_info` VALUES (526, NULL, NULL, NULL, NULL, '168e0df608926782.jpg', '168e0df608926782.jpg');
INSERT INTO `t_sys_file_info` VALUES (527, NULL, NULL, NULL, NULL, '168e48bfbd326796.png', '168e48bfbd326796.png');
INSERT INTO `t_sys_file_info` VALUES (528, NULL, NULL, NULL, NULL, '168e4ce9b8326800.jpg', '168e4ce9b8326800.jpg');
INSERT INTO `t_sys_file_info` VALUES (529, NULL, NULL, NULL, NULL, '168e55f210126806.png', '168e55f210126806.png');
INSERT INTO `t_sys_file_info` VALUES (530, NULL, NULL, NULL, NULL, '168e57ec05f26808.jpeg', '168e57ec05f26808.jpeg');
INSERT INTO `t_sys_file_info` VALUES (531, NULL, NULL, NULL, NULL, '168e9be7ee326833.jpg', '168e9be7ee326833.jpg');
INSERT INTO `t_sys_file_info` VALUES (532, NULL, NULL, NULL, NULL, '168e9c245f926836.jpg', '168e9c245f926836.jpg');
INSERT INTO `t_sys_file_info` VALUES (533, NULL, NULL, NULL, NULL, '168e9d856dd26842.jpg', '168e9d856dd26842.jpg');
INSERT INTO `t_sys_file_info` VALUES (534, NULL, NULL, NULL, NULL, '168e9e09a7b26845.jpg', '168e9e09a7b26845.jpg');
INSERT INTO `t_sys_file_info` VALUES (535, NULL, NULL, NULL, NULL, '168e9fba6a326850.png', '168e9fba6a326850.png');
INSERT INTO `t_sys_file_info` VALUES (536, NULL, NULL, NULL, NULL, '168ea94f61226861.jpg', '168ea94f61226861.jpg');
INSERT INTO `t_sys_file_info` VALUES (537, NULL, NULL, NULL, NULL, '168ea95213a26862.jpg', '168ea95213a26862.jpg');
INSERT INTO `t_sys_file_info` VALUES (538, NULL, NULL, NULL, NULL, '168ead4825526871.jpg', '168ead4825526871.jpg');
INSERT INTO `t_sys_file_info` VALUES (539, NULL, NULL, NULL, NULL, '168ead6944126872.jpg', '168ead6944126872.jpg');
INSERT INTO `t_sys_file_info` VALUES (540, NULL, NULL, NULL, NULL, '168eb05e95c26887.png', '168eb05e95c26887.png');
INSERT INTO `t_sys_file_info` VALUES (541, NULL, NULL, NULL, NULL, '168ef3d876d26920.png', '168ef3d876d26920.png');
INSERT INTO `t_sys_file_info` VALUES (542, NULL, NULL, NULL, NULL, '168ef3f88fa26926.png', '168ef3f88fa26926.png');
INSERT INTO `t_sys_file_info` VALUES (543, NULL, NULL, NULL, NULL, '168ef43425f26927.png', '168ef43425f26927.png');
INSERT INTO `t_sys_file_info` VALUES (544, NULL, NULL, NULL, NULL, '168ef44bd7c26928.png', '168ef44bd7c26928.png');
INSERT INTO `t_sys_file_info` VALUES (545, NULL, NULL, NULL, NULL, '168ef457e9026929.png', '168ef457e9026929.png');
INSERT INTO `t_sys_file_info` VALUES (546, NULL, NULL, NULL, NULL, '168efa8dca026936.jpg', '168efa8dca026936.jpg');
INSERT INTO `t_sys_file_info` VALUES (547, NULL, NULL, NULL, NULL, '168efee2edc26956.png', '168efee2edc26956.png');
INSERT INTO `t_sys_file_info` VALUES (548, NULL, NULL, NULL, NULL, '168f00e158626975.jpg', '168f00e158626975.jpg');
INSERT INTO `t_sys_file_info` VALUES (549, NULL, NULL, NULL, NULL, '168f012838626976.jpg', '168f012838626976.jpg');
INSERT INTO `t_sys_file_info` VALUES (550, NULL, NULL, NULL, NULL, '168f0434f4226984.png', '168f0434f4226984.png');
INSERT INTO `t_sys_file_info` VALUES (551, NULL, NULL, NULL, NULL, '168f101025126991.jpg', '168f101025126991.jpg');
INSERT INTO `t_sys_file_info` VALUES (552, NULL, NULL, NULL, NULL, '168f557038c27018.jpg', '168f557038c27018.jpg');
INSERT INTO `t_sys_file_info` VALUES (553, NULL, NULL, NULL, NULL, '168f688b3c027026.png', '168f688b3c027026.png');
INSERT INTO `t_sys_file_info` VALUES (554, NULL, NULL, NULL, NULL, '168fb4e3be027033.png', '168fb4e3be027033.png');
INSERT INTO `t_sys_file_info` VALUES (555, NULL, NULL, NULL, NULL, '168fc04eaf327040.jpg', '168fc04eaf327040.jpg');
INSERT INTO `t_sys_file_info` VALUES (556, NULL, NULL, NULL, NULL, '168fc063d4d27042.jpg', '168fc063d4d27042.jpg');
INSERT INTO `t_sys_file_info` VALUES (557, NULL, NULL, NULL, NULL, '168fc09cf0c27043.jpg', '168fc09cf0c27043.jpg');
INSERT INTO `t_sys_file_info` VALUES (558, NULL, NULL, NULL, NULL, '168fc10eaa827046.jpg', '168fc10eaa827046.jpg');
INSERT INTO `t_sys_file_info` VALUES (559, NULL, NULL, NULL, NULL, '168ff846d2027072.png', '168ff846d2027072.png');
INSERT INTO `t_sys_file_info` VALUES (560, NULL, NULL, NULL, NULL, '168ffad635327078.jpg', '168ffad635327078.jpg');
INSERT INTO `t_sys_file_info` VALUES (561, NULL, NULL, NULL, NULL, '168ffbff75b27081.jpg', '168ffbff75b27081.jpg');
INSERT INTO `t_sys_file_info` VALUES (562, NULL, NULL, NULL, NULL, '169000f21ef27094.jpg', '169000f21ef27094.jpg');
INSERT INTO `t_sys_file_info` VALUES (563, NULL, NULL, NULL, NULL, '16900d4b73b27099.png', '16900d4b73b27099.png');
INSERT INTO `t_sys_file_info` VALUES (564, NULL, NULL, NULL, NULL, '1690438bc4527124.png', '1690438bc4527124.png');
INSERT INTO `t_sys_file_info` VALUES (565, NULL, NULL, NULL, NULL, '169044349a827125.jpg', '169044349a827125.jpg');
INSERT INTO `t_sys_file_info` VALUES (566, NULL, NULL, NULL, NULL, '169047474ea27134.jpg', '169047474ea27134.jpg');
INSERT INTO `t_sys_file_info` VALUES (567, NULL, NULL, NULL, NULL, '169047fe33327137.jpg', '169047fe33327137.jpg');
INSERT INTO `t_sys_file_info` VALUES (568, NULL, NULL, NULL, NULL, '16904ab516727150.png', '16904ab516727150.png');
INSERT INTO `t_sys_file_info` VALUES (569, NULL, NULL, NULL, NULL, '16904ca377c27156.jpg', '16904ca377c27156.jpg');
INSERT INTO `t_sys_file_info` VALUES (570, NULL, NULL, NULL, NULL, '16904cb86eb27157.jpg', '16904cb86eb27157.jpg');
INSERT INTO `t_sys_file_info` VALUES (571, NULL, NULL, NULL, NULL, '169051f56c727174.jpg', '169051f56c727174.jpg');
INSERT INTO `t_sys_file_info` VALUES (572, NULL, NULL, NULL, NULL, '1690528515e27177.png', '1690528515e27177.png');
INSERT INTO `t_sys_file_info` VALUES (573, NULL, NULL, NULL, NULL, '16906136d6727184.jpg', '16906136d6727184.jpg');
INSERT INTO `t_sys_file_info` VALUES (574, NULL, NULL, NULL, NULL, '16908a1905a27251.png', '16908a1905a27251.png');
INSERT INTO `t_sys_file_info` VALUES (575, NULL, NULL, NULL, NULL, '16908a4e08927255.png', '16908a4e08927255.png');
INSERT INTO `t_sys_file_info` VALUES (576, NULL, NULL, NULL, NULL, '16908a60dd927257.png', '16908a60dd927257.png');
INSERT INTO `t_sys_file_info` VALUES (577, NULL, NULL, NULL, NULL, '16909b2f73b27308.jpg', '16909b2f73b27308.jpg');
INSERT INTO `t_sys_file_info` VALUES (578, NULL, NULL, NULL, NULL, '16909b4c49b27309.jpg', '16909b4c49b27309.jpg');
INSERT INTO `t_sys_file_info` VALUES (579, NULL, NULL, NULL, NULL, '16909ca888a27315.png', '16909ca888a27315.png');
INSERT INTO `t_sys_file_info` VALUES (580, NULL, NULL, NULL, NULL, '1690a0c126827323.jpg', '1690a0c126827323.jpg');
INSERT INTO `t_sys_file_info` VALUES (581, NULL, NULL, NULL, NULL, '1690a29fc5427326.jpg', '1690a29fc5427326.jpg');
INSERT INTO `t_sys_file_info` VALUES (582, NULL, NULL, NULL, NULL, '1690a54608227330.jpg', '1690a54608227330.jpg');
INSERT INTO `t_sys_file_info` VALUES (583, NULL, NULL, NULL, NULL, '1690d57275a27346.jpg', '1690d57275a27346.jpg');
INSERT INTO `t_sys_file_info` VALUES (584, NULL, NULL, NULL, NULL, '1690dcb238727355.jpg', '1690dcb238727355.jpg');
INSERT INTO `t_sys_file_info` VALUES (585, NULL, NULL, NULL, NULL, '1690eb5583727368.png', '1690eb5583727368.png');
INSERT INTO `t_sys_file_info` VALUES (586, NULL, NULL, NULL, NULL, '1690eb6d61f27371.png', '1690eb6d61f27371.png');
INSERT INTO `t_sys_file_info` VALUES (587, NULL, NULL, NULL, NULL, '1690eb9391b27372.png', '1690eb9391b27372.png');
INSERT INTO `t_sys_file_info` VALUES (588, NULL, NULL, NULL, NULL, '1690ef7e49527374.png', '1690ef7e49527374.png');
INSERT INTO `t_sys_file_info` VALUES (589, NULL, NULL, NULL, NULL, '1690efa409627377.jpg', '1690efa409627377.jpg');
INSERT INTO `t_sys_file_info` VALUES (590, NULL, NULL, NULL, NULL, '1690f3e9d9027388.jpg', '1690f3e9d9027388.jpg');
INSERT INTO `t_sys_file_info` VALUES (591, NULL, NULL, NULL, NULL, '16912ca3cdf27422.jpeg', '16912ca3cdf27422.jpeg');
INSERT INTO `t_sys_file_info` VALUES (592, NULL, NULL, NULL, NULL, '1691304f56527425.png', '1691304f56527425.png');
INSERT INTO `t_sys_file_info` VALUES (593, NULL, NULL, NULL, NULL, '1691321d89627430.jpg', '1691321d89627430.jpg');
INSERT INTO `t_sys_file_info` VALUES (594, NULL, NULL, NULL, NULL, '16913bd8c2827446.jpg', '16913bd8c2827446.jpg');
INSERT INTO `t_sys_file_info` VALUES (595, NULL, NULL, NULL, NULL, '169141cde3c27458.jpg', '169141cde3c27458.jpg');
INSERT INTO `t_sys_file_info` VALUES (596, NULL, NULL, NULL, NULL, '1691424aa9027461.jpg', '1691424aa9027461.jpg');
INSERT INTO `t_sys_file_info` VALUES (597, NULL, NULL, NULL, NULL, '16914cafda027475.jpg', '16914cafda027475.jpg');
INSERT INTO `t_sys_file_info` VALUES (598, NULL, NULL, NULL, NULL, '169190da5d327492.jpg', '169190da5d327492.jpg');
INSERT INTO `t_sys_file_info` VALUES (599, NULL, NULL, NULL, NULL, '169191aa86e27497.png', '169191aa86e27497.png');
INSERT INTO `t_sys_file_info` VALUES (600, NULL, NULL, NULL, NULL, '1691932e4b827499.jpg', '1691932e4b827499.jpg');
INSERT INTO `t_sys_file_info` VALUES (601, NULL, NULL, NULL, NULL, '169194be48627502.jpg', '169194be48627502.jpg');
INSERT INTO `t_sys_file_info` VALUES (602, NULL, NULL, NULL, NULL, '1691953580727503.jpg', '1691953580727503.jpg');
INSERT INTO `t_sys_file_info` VALUES (603, NULL, NULL, NULL, NULL, '1691a0d668427505.jpg', '1691a0d668427505.jpg');
INSERT INTO `t_sys_file_info` VALUES (604, NULL, NULL, NULL, NULL, '1691a5d381d27506.png', '1691a5d381d27506.png');
INSERT INTO `t_sys_file_info` VALUES (605, NULL, NULL, NULL, NULL, '1691b08da1827510.jpg', '1691b08da1827510.jpg');
INSERT INTO `t_sys_file_info` VALUES (606, NULL, NULL, NULL, NULL, '1691f74045e27523.jpg', '1691f74045e27523.jpg');
INSERT INTO `t_sys_file_info` VALUES (607, NULL, NULL, NULL, NULL, '169227b35b027546.png', '169227b35b027546.png');
INSERT INTO `t_sys_file_info` VALUES (608, NULL, NULL, NULL, NULL, '16922aa32a027549.jpg', '16922aa32a027549.jpg');
INSERT INTO `t_sys_file_info` VALUES (609, NULL, NULL, NULL, NULL, '1692358798d27555.jpg', '1692358798d27555.jpg');
INSERT INTO `t_sys_file_info` VALUES (610, NULL, NULL, NULL, NULL, '169235acae227556.jpg', '169235acae227556.jpg');
INSERT INTO `t_sys_file_info` VALUES (611, NULL, NULL, NULL, NULL, '16923da29b427575.png', '16923da29b427575.png');
INSERT INTO `t_sys_file_info` VALUES (612, NULL, NULL, NULL, NULL, '16923db253d27576.png', '16923db253d27576.png');
INSERT INTO `t_sys_file_info` VALUES (613, NULL, NULL, NULL, NULL, '16923dd957e27577.jpg', '16923dd957e27577.jpg');
INSERT INTO `t_sys_file_info` VALUES (614, NULL, NULL, NULL, NULL, '16923e61fef27578.jpg', '16923e61fef27578.jpg');
INSERT INTO `t_sys_file_info` VALUES (615, NULL, NULL, NULL, NULL, '1692413234e27589.jpg', '1692413234e27589.jpg');
INSERT INTO `t_sys_file_info` VALUES (616, NULL, NULL, NULL, NULL, '16925b828bf27602.jpg', '16925b828bf27602.jpg');
INSERT INTO `t_sys_file_info` VALUES (617, NULL, NULL, NULL, NULL, '16925ce688027605.jpg', '16925ce688027605.jpg');
INSERT INTO `t_sys_file_info` VALUES (618, NULL, NULL, NULL, NULL, '16925d56c5b27608.jpg', '16925d56c5b27608.jpg');
INSERT INTO `t_sys_file_info` VALUES (619, NULL, NULL, NULL, NULL, '16925ed0d9927611.jpg', '16925ed0d9927611.jpg');
INSERT INTO `t_sys_file_info` VALUES (620, NULL, NULL, NULL, NULL, '16925ef76a727614.jpg', '16925ef76a727614.jpg');
INSERT INTO `t_sys_file_info` VALUES (621, NULL, NULL, NULL, NULL, '16925f5795327620.jpg', '16925f5795327620.jpg');
INSERT INTO `t_sys_file_info` VALUES (622, NULL, NULL, NULL, NULL, '16925f8d14927623.jpg', '16925f8d14927623.jpg');
INSERT INTO `t_sys_file_info` VALUES (623, NULL, NULL, NULL, NULL, '16925fad28127626.png', '16925fad28127626.png');
INSERT INTO `t_sys_file_info` VALUES (624, NULL, NULL, NULL, NULL, '169278aa31a27630.png', '169278aa31a27630.png');
INSERT INTO `t_sys_file_info` VALUES (625, NULL, NULL, NULL, NULL, '169278cc5fd27633.png', '169278cc5fd27633.png');
INSERT INTO `t_sys_file_info` VALUES (626, NULL, NULL, NULL, NULL, '16927d0128827638.png', '16927d0128827638.png');
INSERT INTO `t_sys_file_info` VALUES (627, NULL, NULL, NULL, NULL, '16928be27f227669.jpg', '16928be27f227669.jpg');
INSERT INTO `t_sys_file_info` VALUES (628, NULL, NULL, NULL, NULL, '16928bf78ae27670.jpg', '16928bf78ae27670.jpg');
INSERT INTO `t_sys_file_info` VALUES (629, NULL, NULL, NULL, NULL, '16928c1ffa527672.png', '16928c1ffa527672.png');
INSERT INTO `t_sys_file_info` VALUES (630, NULL, NULL, NULL, NULL, '16929cdd73627685.jpg', '16929cdd73627685.jpg');
INSERT INTO `t_sys_file_info` VALUES (631, NULL, NULL, NULL, NULL, '1692a23b02e27688.jpg', '1692a23b02e27688.jpg');
INSERT INTO `t_sys_file_info` VALUES (632, NULL, NULL, NULL, NULL, '1692cb3000127711.png', '1692cb3000127711.png');
INSERT INTO `t_sys_file_info` VALUES (633, NULL, NULL, NULL, NULL, '1692cb4e29727714.png', '1692cb4e29727714.png');
INSERT INTO `t_sys_file_info` VALUES (634, NULL, NULL, NULL, NULL, '1692ceed47f27720.jpg', '1692ceed47f27720.jpg');
INSERT INTO `t_sys_file_info` VALUES (635, NULL, NULL, NULL, NULL, '1692cfa483827723.jpg', '1692cfa483827723.jpg');
INSERT INTO `t_sys_file_info` VALUES (636, NULL, NULL, NULL, NULL, '1692d89c2c127734.jpg', '1692d89c2c127734.jpg');
INSERT INTO `t_sys_file_info` VALUES (637, NULL, NULL, NULL, NULL, '1692daab26a27742.jpg', '1692daab26a27742.jpg');
INSERT INTO `t_sys_file_info` VALUES (638, NULL, NULL, NULL, NULL, '1692dabb41c27743.png', '1692dabb41c27743.png');
INSERT INTO `t_sys_file_info` VALUES (639, NULL, NULL, NULL, NULL, '1692dd7fda727749.png', '1692dd7fda727749.png');
INSERT INTO `t_sys_file_info` VALUES (640, NULL, NULL, NULL, NULL, '1692e0b742527757.jpg', '1692e0b742527757.jpg');
INSERT INTO `t_sys_file_info` VALUES (641, NULL, NULL, NULL, NULL, '1692e0f044f27758.jpg', '1692e0f044f27758.jpg');
INSERT INTO `t_sys_file_info` VALUES (642, NULL, NULL, NULL, NULL, '1692e0f0c7427759.png', '1692e0f0c7427759.png');
INSERT INTO `t_sys_file_info` VALUES (643, NULL, NULL, NULL, NULL, '1692f6088bf27796.jpg', '1692f6088bf27796.jpg');
INSERT INTO `t_sys_file_info` VALUES (644, NULL, NULL, NULL, NULL, '1693010daaa27804.jpg', '1693010daaa27804.jpg');
INSERT INTO `t_sys_file_info` VALUES (645, NULL, NULL, NULL, NULL, '1693017030827805.jpg', '1693017030827805.jpg');
INSERT INTO `t_sys_file_info` VALUES (646, NULL, NULL, NULL, NULL, '16932410e5627830.jpg', '16932410e5627830.jpg');
INSERT INTO `t_sys_file_info` VALUES (647, NULL, NULL, NULL, NULL, '169331fa85d27861.png', '169331fa85d27861.png');
INSERT INTO `t_sys_file_info` VALUES (648, NULL, NULL, NULL, NULL, '169335ab67f27872.jpg', '169335ab67f27872.jpg');
INSERT INTO `t_sys_file_info` VALUES (649, NULL, NULL, NULL, NULL, '169335b328627873.jpg', '169335b328627873.jpg');
INSERT INTO `t_sys_file_info` VALUES (650, NULL, NULL, NULL, NULL, '169335b578927874.jpg', '169335b578927874.jpg');
INSERT INTO `t_sys_file_info` VALUES (651, NULL, NULL, NULL, NULL, '1693467ff5c27884.jpg', '1693467ff5c27884.jpg');
INSERT INTO `t_sys_file_info` VALUES (652, NULL, NULL, NULL, NULL, '169346c88aa27887.jpeg', '169346c88aa27887.jpeg');
INSERT INTO `t_sys_file_info` VALUES (653, NULL, NULL, NULL, NULL, '16934757cc527888.jpeg', '16934757cc527888.jpeg');
INSERT INTO `t_sys_file_info` VALUES (654, NULL, NULL, NULL, NULL, '169347e998527889.jpeg', '169347e998527889.jpeg');
INSERT INTO `t_sys_file_info` VALUES (655, NULL, NULL, NULL, NULL, '16934841ff527890.jpeg', '16934841ff527890.jpeg');
INSERT INTO `t_sys_file_info` VALUES (656, NULL, NULL, NULL, NULL, '1693496aea727891.jpeg', '1693496aea727891.jpeg');
INSERT INTO `t_sys_file_info` VALUES (657, NULL, NULL, NULL, NULL, '169349cf42727893.jpeg', '169349cf42727893.jpeg');
INSERT INTO `t_sys_file_info` VALUES (658, NULL, NULL, NULL, NULL, '16934db601227894.jpg', '16934db601227894.jpg');
INSERT INTO `t_sys_file_info` VALUES (659, NULL, NULL, NULL, NULL, '169355fef9127908.jpg', '169355fef9127908.jpg');
INSERT INTO `t_sys_file_info` VALUES (660, NULL, NULL, NULL, NULL, '1693708219327917.jpg', '1693708219327917.jpg');
INSERT INTO `t_sys_file_info` VALUES (661, NULL, NULL, NULL, NULL, '169374dcb2827925.jpg', '169374dcb2827925.jpg');
INSERT INTO `t_sys_file_info` VALUES (662, NULL, NULL, NULL, NULL, '1693800682727933.jpg', '1693800682727933.jpg');
INSERT INTO `t_sys_file_info` VALUES (663, NULL, NULL, NULL, NULL, '16938017b5927937.jpg', '16938017b5927937.jpg');
INSERT INTO `t_sys_file_info` VALUES (664, NULL, NULL, NULL, NULL, '1693803091227938.jpg', '1693803091227938.jpg');
INSERT INTO `t_sys_file_info` VALUES (665, NULL, NULL, NULL, NULL, '1693897e94327954.png', '1693897e94327954.png');
INSERT INTO `t_sys_file_info` VALUES (666, NULL, NULL, NULL, NULL, '16938e5274427960.jpg', '16938e5274427960.jpg');
INSERT INTO `t_sys_file_info` VALUES (667, NULL, NULL, NULL, NULL, '16938e5c1b927961.jpg', '16938e5c1b927961.jpg');
INSERT INTO `t_sys_file_info` VALUES (668, NULL, NULL, NULL, NULL, '169395ec49b27967.jpg', '169395ec49b27967.jpg');
INSERT INTO `t_sys_file_info` VALUES (669, NULL, NULL, NULL, NULL, '1693e53c91228003.jpg', '1693e53c91228003.jpg');
INSERT INTO `t_sys_file_info` VALUES (670, NULL, NULL, NULL, NULL, '16943a86cfc28021.png', '16943a86cfc28021.png');
INSERT INTO `t_sys_file_info` VALUES (671, NULL, NULL, NULL, NULL, '1694434951528022.jpg', '1694434951528022.jpg');
INSERT INTO `t_sys_file_info` VALUES (672, NULL, NULL, NULL, NULL, '16946e09a4628040.jpg', '16946e09a4628040.jpg');
INSERT INTO `t_sys_file_info` VALUES (673, NULL, NULL, NULL, NULL, '16946e0fbd828043.jpg', '16946e0fbd828043.jpg');
INSERT INTO `t_sys_file_info` VALUES (674, NULL, NULL, NULL, NULL, '16947b6b95928058.jpg', '16947b6b95928058.jpg');
INSERT INTO `t_sys_file_info` VALUES (675, NULL, NULL, NULL, NULL, '16947eb2dec28062.png', '16947eb2dec28062.png');
INSERT INTO `t_sys_file_info` VALUES (676, NULL, NULL, NULL, NULL, '16949b50f2d28075.jpeg', '16949b50f2d28075.jpeg');
INSERT INTO `t_sys_file_info` VALUES (677, NULL, NULL, NULL, NULL, '1694b98782228080.png', '1694b98782228080.png');
INSERT INTO `t_sys_file_info` VALUES (678, NULL, NULL, NULL, NULL, '1694bc2a60428086.jpg', '1694bc2a60428086.jpg');
INSERT INTO `t_sys_file_info` VALUES (679, NULL, NULL, NULL, NULL, '1694bc2f42028088.png', '1694bc2f42028088.png');
INSERT INTO `t_sys_file_info` VALUES (680, NULL, NULL, NULL, NULL, '1694c7796c428100.jpg', '1694c7796c428100.jpg');
INSERT INTO `t_sys_file_info` VALUES (681, NULL, NULL, NULL, NULL, '1694c7ad75228101.jpg', '1694c7ad75228101.jpg');
INSERT INTO `t_sys_file_info` VALUES (682, NULL, NULL, NULL, NULL, '1694c8eebc528106.png', '1694c8eebc528106.png');
INSERT INTO `t_sys_file_info` VALUES (683, NULL, NULL, NULL, NULL, '1694c91502228109.png', '1694c91502228109.png');
INSERT INTO `t_sys_file_info` VALUES (684, NULL, NULL, NULL, NULL, '1694caced9828115.png', '1694caced9828115.png');
INSERT INTO `t_sys_file_info` VALUES (685, NULL, NULL, NULL, NULL, '1694cb0980428118.jpg', '1694cb0980428118.jpg');
INSERT INTO `t_sys_file_info` VALUES (686, NULL, NULL, NULL, NULL, '1694ce5475e28122.jpg', '1694ce5475e28122.jpg');
INSERT INTO `t_sys_file_info` VALUES (687, NULL, NULL, NULL, NULL, '1694d3b329e28140.jpg', '1694d3b329e28140.jpg');
INSERT INTO `t_sys_file_info` VALUES (688, NULL, NULL, NULL, NULL, '1694d3c66b828141.jpg', '1694d3c66b828141.jpg');
INSERT INTO `t_sys_file_info` VALUES (689, NULL, NULL, NULL, NULL, '1694d418ede28143.jpg', '1694d418ede28143.jpg');
INSERT INTO `t_sys_file_info` VALUES (690, NULL, NULL, NULL, NULL, '1694d429e3d28146.jpg', '1694d429e3d28146.jpg');
INSERT INTO `t_sys_file_info` VALUES (691, NULL, NULL, NULL, NULL, '1694dbe65ae28153.jpg', '1694dbe65ae28153.jpg');
INSERT INTO `t_sys_file_info` VALUES (692, NULL, NULL, NULL, NULL, '1694e10391928157.jpg', '1694e10391928157.jpg');
INSERT INTO `t_sys_file_info` VALUES (693, NULL, NULL, NULL, NULL, '1694ea9892e28164.jpg', '1694ea9892e28164.jpg');
INSERT INTO `t_sys_file_info` VALUES (694, NULL, NULL, NULL, NULL, '1695082c23628172.png', '1695082c23628172.png');
INSERT INTO `t_sys_file_info` VALUES (695, NULL, NULL, NULL, NULL, '16950c3224628188.jpg', '16950c3224628188.jpg');
INSERT INTO `t_sys_file_info` VALUES (696, NULL, NULL, NULL, NULL, '16950c4739228191.jpg', '16950c4739228191.jpg');
INSERT INTO `t_sys_file_info` VALUES (697, NULL, NULL, NULL, NULL, '16950d2ac9b28192.jpg', '16950d2ac9b28192.jpg');
INSERT INTO `t_sys_file_info` VALUES (698, NULL, NULL, NULL, NULL, '169519feb3928221.png', '169519feb3928221.png');
INSERT INTO `t_sys_file_info` VALUES (699, NULL, NULL, NULL, NULL, '16951a98f6028222.jpg', '16951a98f6028222.jpg');
INSERT INTO `t_sys_file_info` VALUES (700, NULL, NULL, NULL, NULL, '16951aa4f3d28223.jpg', '16951aa4f3d28223.jpg');
INSERT INTO `t_sys_file_info` VALUES (701, NULL, NULL, NULL, NULL, '16951ab198928224.jpg', '16951ab198928224.jpg');
INSERT INTO `t_sys_file_info` VALUES (702, NULL, NULL, NULL, NULL, '16951b0df2c28229.jpg', '16951b0df2c28229.jpg');
INSERT INTO `t_sys_file_info` VALUES (703, NULL, NULL, NULL, NULL, '16951b24bfc28230.jpg', '16951b24bfc28230.jpg');
INSERT INTO `t_sys_file_info` VALUES (704, NULL, NULL, NULL, NULL, '16951b60c0c28232.jpg', '16951b60c0c28232.jpg');
INSERT INTO `t_sys_file_info` VALUES (705, NULL, NULL, NULL, NULL, '16951cc007428236.jpg', '16951cc007428236.jpg');
INSERT INTO `t_sys_file_info` VALUES (706, NULL, NULL, NULL, NULL, '16951d6662328239.jpg', '16951d6662328239.jpg');
INSERT INTO `t_sys_file_info` VALUES (707, NULL, NULL, NULL, NULL, '16951e795c928243.png', '16951e795c928243.png');
INSERT INTO `t_sys_file_info` VALUES (708, NULL, NULL, NULL, NULL, '1695200d8e928247.png', '1695200d8e928247.png');
INSERT INTO `t_sys_file_info` VALUES (709, NULL, NULL, NULL, NULL, '16952bc3a1428261.jpg', '16952bc3a1428261.jpg');
INSERT INTO `t_sys_file_info` VALUES (710, NULL, NULL, NULL, NULL, '16953bd7e2d28275.jpg', '16953bd7e2d28275.jpg');
INSERT INTO `t_sys_file_info` VALUES (711, NULL, NULL, NULL, NULL, '169540ec5fa28277.jpg', '169540ec5fa28277.jpg');
INSERT INTO `t_sys_file_info` VALUES (712, NULL, NULL, NULL, NULL, '169541553af28281.jpg', '169541553af28281.jpg');
INSERT INTO `t_sys_file_info` VALUES (713, NULL, NULL, NULL, NULL, '169541688c828282.jpg', '169541688c828282.jpg');
INSERT INTO `t_sys_file_info` VALUES (714, NULL, NULL, NULL, NULL, '1695614290728287.jpg', '1695614290728287.jpg');
INSERT INTO `t_sys_file_info` VALUES (715, NULL, NULL, NULL, NULL, '169563f2d6b28291.png', '169563f2d6b28291.png');
INSERT INTO `t_sys_file_info` VALUES (716, NULL, NULL, NULL, NULL, '16956cc79e928301.jpg', '16956cc79e928301.jpg');
INSERT INTO `t_sys_file_info` VALUES (717, NULL, NULL, NULL, NULL, '16956de5d9628304.jpg', '16956de5d9628304.jpg');
INSERT INTO `t_sys_file_info` VALUES (718, NULL, NULL, NULL, NULL, '1695701cf1828312.jpg', '1695701cf1828312.jpg');
INSERT INTO `t_sys_file_info` VALUES (719, NULL, NULL, NULL, NULL, '16957156d4028314.jpg', '16957156d4028314.jpg');
INSERT INTO `t_sys_file_info` VALUES (720, NULL, NULL, NULL, NULL, '1695721795e28315.png', '1695721795e28315.png');
INSERT INTO `t_sys_file_info` VALUES (721, NULL, NULL, NULL, NULL, '169575dfe3128319.jpg', '169575dfe3128319.jpg');
INSERT INTO `t_sys_file_info` VALUES (722, NULL, NULL, NULL, NULL, '169576c097928322.jpg', '169576c097928322.jpg');
INSERT INTO `t_sys_file_info` VALUES (723, NULL, NULL, NULL, NULL, '169578d72a328324.jpg', '169578d72a328324.jpg');
INSERT INTO `t_sys_file_info` VALUES (724, NULL, NULL, NULL, NULL, '1695828711128331.png', '1695828711128331.png');
INSERT INTO `t_sys_file_info` VALUES (725, NULL, NULL, NULL, NULL, '1695828c4b428333.png', '1695828c4b428333.png');
INSERT INTO `t_sys_file_info` VALUES (726, NULL, NULL, NULL, NULL, '169582d472b28336.png', '169582d472b28336.png');
INSERT INTO `t_sys_file_info` VALUES (727, NULL, NULL, NULL, NULL, '169582da62928337.png', '169582da62928337.png');
INSERT INTO `t_sys_file_info` VALUES (728, NULL, NULL, NULL, NULL, '1695880796828339.jpg', '1695880796828339.jpg');
INSERT INTO `t_sys_file_info` VALUES (729, NULL, NULL, NULL, NULL, '16958819f6328340.jpg', '16958819f6328340.jpg');
INSERT INTO `t_sys_file_info` VALUES (730, NULL, NULL, NULL, NULL, '16958826b0528341.jpg', '16958826b0528341.jpg');
INSERT INTO `t_sys_file_info` VALUES (731, NULL, NULL, NULL, NULL, '1695900a36928355.jpg', '1695900a36928355.jpg');
INSERT INTO `t_sys_file_info` VALUES (732, NULL, NULL, NULL, NULL, '169590441df28356.jpg', '169590441df28356.jpg');
INSERT INTO `t_sys_file_info` VALUES (733, NULL, NULL, NULL, NULL, '1695910e8f328364.jpg', '1695910e8f328364.jpg');
INSERT INTO `t_sys_file_info` VALUES (734, NULL, NULL, NULL, NULL, '1695b20305228375.png', '1695b20305228375.png');
INSERT INTO `t_sys_file_info` VALUES (735, NULL, NULL, NULL, NULL, '1695b49fb6a28381.jpeg', '1695b49fb6a28381.jpeg');
INSERT INTO `t_sys_file_info` VALUES (736, NULL, NULL, NULL, NULL, '1695b5dd1e928385.jpg', '1695b5dd1e928385.jpg');
INSERT INTO `t_sys_file_info` VALUES (737, NULL, NULL, NULL, NULL, '1695c258b1528402.png', '1695c258b1528402.png');
INSERT INTO `t_sys_file_info` VALUES (738, NULL, NULL, NULL, NULL, '1695c37836628403.jpg', '1695c37836628403.jpg');
INSERT INTO `t_sys_file_info` VALUES (739, NULL, NULL, NULL, NULL, '1695c38aca328404.png', '1695c38aca328404.png');
INSERT INTO `t_sys_file_info` VALUES (740, NULL, NULL, NULL, NULL, '1695c3cc2de28405.png', '1695c3cc2de28405.png');
INSERT INTO `t_sys_file_info` VALUES (741, NULL, NULL, NULL, NULL, '1695c48800928406.png', '1695c48800928406.png');
INSERT INTO `t_sys_file_info` VALUES (742, NULL, NULL, NULL, NULL, '1695c49766b28408.png', '1695c49766b28408.png');
INSERT INTO `t_sys_file_info` VALUES (743, NULL, NULL, NULL, NULL, '1695c59da1328415.png', '1695c59da1328415.png');
INSERT INTO `t_sys_file_info` VALUES (744, NULL, NULL, NULL, NULL, '1695c5e26b028419.jpg', '1695c5e26b028419.jpg');
INSERT INTO `t_sys_file_info` VALUES (745, NULL, NULL, NULL, NULL, '1695c60fd4d28423.png', '1695c60fd4d28423.png');
INSERT INTO `t_sys_file_info` VALUES (746, NULL, NULL, NULL, NULL, '1695c875b3328433.jpg', '1695c875b3328433.jpg');
INSERT INTO `t_sys_file_info` VALUES (747, NULL, NULL, NULL, NULL, '1695c8dc51f28434.jpg', '1695c8dc51f28434.jpg');
INSERT INTO `t_sys_file_info` VALUES (748, NULL, NULL, NULL, NULL, '1695d67d20228461.jpg', '1695d67d20228461.jpg');
INSERT INTO `t_sys_file_info` VALUES (749, NULL, NULL, NULL, NULL, '1695dbeb21f28462.jpg', '1695dbeb21f28462.jpg');
INSERT INTO `t_sys_file_info` VALUES (750, NULL, NULL, NULL, NULL, '169610d434f28469.jpg', '169610d434f28469.jpg');
INSERT INTO `t_sys_file_info` VALUES (751, NULL, NULL, NULL, NULL, '1696140545528472.png', '1696140545528472.png');
INSERT INTO `t_sys_file_info` VALUES (752, NULL, NULL, NULL, NULL, '16961f3abb828477.png', '16961f3abb828477.png');
INSERT INTO `t_sys_file_info` VALUES (753, NULL, NULL, NULL, NULL, '1696216223d28487.png', '1696216223d28487.png');
INSERT INTO `t_sys_file_info` VALUES (754, NULL, NULL, NULL, NULL, '1696286797628488.jpg', '1696286797628488.jpg');
INSERT INTO `t_sys_file_info` VALUES (755, NULL, NULL, NULL, NULL, '1696289550028491.jpg', '1696289550028491.jpg');
INSERT INTO `t_sys_file_info` VALUES (756, NULL, NULL, NULL, NULL, '16962e4992d28497.png', '16962e4992d28497.png');
INSERT INTO `t_sys_file_info` VALUES (757, NULL, NULL, NULL, NULL, '16965f06d6328499.jpg', '16965f06d6328499.jpg');
INSERT INTO `t_sys_file_info` VALUES (758, NULL, NULL, NULL, NULL, '16965f0d33728500.jpg', '16965f0d33728500.jpg');
INSERT INTO `t_sys_file_info` VALUES (759, NULL, NULL, NULL, NULL, '1696644e00d28501.jpg', '1696644e00d28501.jpg');
INSERT INTO `t_sys_file_info` VALUES (760, NULL, NULL, NULL, NULL, '1696646adcd28504.jpg', '1696646adcd28504.jpg');
INSERT INTO `t_sys_file_info` VALUES (761, NULL, NULL, NULL, NULL, '16966d2127628512.png', '16966d2127628512.png');
INSERT INTO `t_sys_file_info` VALUES (762, NULL, NULL, NULL, NULL, '169677a101b28520.jpg', '169677a101b28520.jpg');
INSERT INTO `t_sys_file_info` VALUES (763, NULL, NULL, NULL, NULL, '169678b202028522.jpg', '169678b202028522.jpg');
INSERT INTO `t_sys_file_info` VALUES (764, NULL, NULL, NULL, NULL, '16967d7259128525.jpg', '16967d7259128525.jpg');
INSERT INTO `t_sys_file_info` VALUES (765, NULL, NULL, NULL, NULL, '1696a825ee228544.png', '1696a825ee228544.png');
INSERT INTO `t_sys_file_info` VALUES (766, NULL, NULL, NULL, NULL, '1696a95a65d28550.jpg', '1696a95a65d28550.jpg');
INSERT INTO `t_sys_file_info` VALUES (767, NULL, NULL, NULL, NULL, '1696ab2f87b28558.jpg', '1696ab2f87b28558.jpg');
INSERT INTO `t_sys_file_info` VALUES (768, NULL, NULL, NULL, NULL, '1696ab58ad628559.png', '1696ab58ad628559.png');
INSERT INTO `t_sys_file_info` VALUES (769, NULL, NULL, NULL, NULL, '1696ab7ec5128560.jpg', '1696ab7ec5128560.jpg');
INSERT INTO `t_sys_file_info` VALUES (770, NULL, NULL, NULL, NULL, '1696abfe20928563.png', '1696abfe20928563.png');
INSERT INTO `t_sys_file_info` VALUES (771, NULL, NULL, NULL, NULL, '1696acdd5f328566.jpg', '1696acdd5f328566.jpg');
INSERT INTO `t_sys_file_info` VALUES (772, NULL, NULL, NULL, NULL, '1696ad900fb28569.jpg', '1696ad900fb28569.jpg');
INSERT INTO `t_sys_file_info` VALUES (773, NULL, NULL, NULL, NULL, '1696adcad4a28571.jpg', '1696adcad4a28571.jpg');
INSERT INTO `t_sys_file_info` VALUES (774, NULL, NULL, NULL, NULL, '1696adcc30928572.png', '1696adcc30928572.png');
INSERT INTO `t_sys_file_info` VALUES (775, NULL, NULL, NULL, NULL, '1696ae45cdb28573.png', '1696ae45cdb28573.png');
INSERT INTO `t_sys_file_info` VALUES (776, NULL, NULL, NULL, NULL, '1696b363f8f28574.png', '1696b363f8f28574.png');
INSERT INTO `t_sys_file_info` VALUES (777, NULL, NULL, NULL, NULL, '1696b36c54e28575.png', '1696b36c54e28575.png');
INSERT INTO `t_sys_file_info` VALUES (778, NULL, NULL, NULL, NULL, '1696b982e0828583.png', '1696b982e0828583.png');
INSERT INTO `t_sys_file_info` VALUES (779, NULL, NULL, NULL, NULL, '1696ba13a3928586.png', '1696ba13a3928586.png');
INSERT INTO `t_sys_file_info` VALUES (780, NULL, NULL, NULL, NULL, '1696ba962df28587.jpg', '1696ba962df28587.jpg');
INSERT INTO `t_sys_file_info` VALUES (781, NULL, NULL, NULL, NULL, '1696bab3dde28590.jpg', '1696bab3dde28590.jpg');
INSERT INTO `t_sys_file_info` VALUES (782, NULL, NULL, NULL, NULL, '1696c0cd91e28609.jpg', '1696c0cd91e28609.jpg');
INSERT INTO `t_sys_file_info` VALUES (783, NULL, NULL, NULL, NULL, '1696d2a3c3f28620.jpg', '1696d2a3c3f28620.jpg');
INSERT INTO `t_sys_file_info` VALUES (784, NULL, NULL, NULL, NULL, '1696fc9492128630.jpg', '1696fc9492128630.jpg');
INSERT INTO `t_sys_file_info` VALUES (785, NULL, NULL, NULL, NULL, '1696ffaed5528637.jpg', '1696ffaed5528637.jpg');
INSERT INTO `t_sys_file_info` VALUES (786, NULL, NULL, NULL, NULL, '1697076d74a28644.png', '1697076d74a28644.png');
INSERT INTO `t_sys_file_info` VALUES (787, NULL, NULL, NULL, NULL, '16970cbb32128660.jpg', '16970cbb32128660.jpg');
INSERT INTO `t_sys_file_info` VALUES (788, NULL, NULL, NULL, NULL, '16971167c3c28708.jpg', '16971167c3c28708.jpg');
INSERT INTO `t_sys_file_info` VALUES (789, NULL, NULL, NULL, NULL, '16971f986b828727.png', '16971f986b828727.png');
INSERT INTO `t_sys_file_info` VALUES (790, NULL, NULL, NULL, NULL, '169721ba5dd28730.jpg', '169721ba5dd28730.jpg');
INSERT INTO `t_sys_file_info` VALUES (791, NULL, NULL, NULL, NULL, '169722dbc0328733.jpg', '169722dbc0328733.jpg');
INSERT INTO `t_sys_file_info` VALUES (792, NULL, NULL, NULL, NULL, '16974a7906428767.jpg', '16974a7906428767.jpg');
INSERT INTO `t_sys_file_info` VALUES (793, NULL, NULL, NULL, NULL, '16974ac8a4d28770.jpg', '16974ac8a4d28770.jpg');
INSERT INTO `t_sys_file_info` VALUES (794, NULL, NULL, NULL, NULL, '16974deadd728784.png', '16974deadd728784.png');
INSERT INTO `t_sys_file_info` VALUES (795, NULL, NULL, NULL, NULL, '16974dfbba828785.png', '16974dfbba828785.png');
INSERT INTO `t_sys_file_info` VALUES (796, NULL, NULL, NULL, NULL, '16974e4ec6228786.jpg', '16974e4ec6228786.jpg');
INSERT INTO `t_sys_file_info` VALUES (797, NULL, NULL, NULL, NULL, '16974e795aa28789.jpg', '16974e795aa28789.jpg');
INSERT INTO `t_sys_file_info` VALUES (798, NULL, NULL, NULL, NULL, '16974fd99c428794.png', '16974fd99c428794.png');
INSERT INTO `t_sys_file_info` VALUES (799, NULL, NULL, NULL, NULL, '1697516f02c28800.png', '1697516f02c28800.png');
INSERT INTO `t_sys_file_info` VALUES (800, NULL, NULL, NULL, NULL, '16975b4df5f28809.png', '16975b4df5f28809.png');
INSERT INTO `t_sys_file_info` VALUES (801, NULL, NULL, NULL, NULL, '16975c970aa28816.jpg', '16975c970aa28816.jpg');
INSERT INTO `t_sys_file_info` VALUES (802, NULL, NULL, NULL, NULL, '16975e7043e28825.jpg', '16975e7043e28825.jpg');
INSERT INTO `t_sys_file_info` VALUES (803, NULL, NULL, NULL, NULL, '1697619b32228832.jpg', '1697619b32228832.jpg');
INSERT INTO `t_sys_file_info` VALUES (804, NULL, NULL, NULL, NULL, '16976e07e6628850.png', '16976e07e6628850.png');
INSERT INTO `t_sys_file_info` VALUES (805, NULL, NULL, NULL, NULL, '16979dde7a028872.jpg', '16979dde7a028872.jpg');
INSERT INTO `t_sys_file_info` VALUES (806, NULL, NULL, NULL, NULL, '1697a17f85628877.jpg', '1697a17f85628877.jpg');
INSERT INTO `t_sys_file_info` VALUES (807, NULL, NULL, NULL, NULL, '1697a92563628887.png', '1697a92563628887.png');
INSERT INTO `t_sys_file_info` VALUES (808, NULL, NULL, NULL, NULL, '1697ad79a7a28893.jpg', '1697ad79a7a28893.jpg');
INSERT INTO `t_sys_file_info` VALUES (809, NULL, NULL, NULL, NULL, '1697b273b4328912.png', '1697b273b4328912.png');
INSERT INTO `t_sys_file_info` VALUES (810, NULL, NULL, NULL, NULL, '1697b4b877728916.jpg', '1697b4b877728916.jpg');
INSERT INTO `t_sys_file_info` VALUES (811, NULL, NULL, NULL, NULL, '1697b5cd40928917.jpg', '1697b5cd40928917.jpg');
INSERT INTO `t_sys_file_info` VALUES (812, NULL, NULL, NULL, NULL, '1697ebb1bd128962.png', '1697ebb1bd128962.png');
INSERT INTO `t_sys_file_info` VALUES (813, NULL, NULL, NULL, NULL, '1697eeab7b428964.jpg', '1697eeab7b428964.jpg');
INSERT INTO `t_sys_file_info` VALUES (814, NULL, NULL, NULL, NULL, '1697fef19fd29003.png', '1697fef19fd29003.png');
INSERT INTO `t_sys_file_info` VALUES (815, NULL, NULL, NULL, NULL, '1697ff507a829008.jpg', '1697ff507a829008.jpg');
INSERT INTO `t_sys_file_info` VALUES (816, NULL, NULL, NULL, NULL, '1697ff579dc29009.jpg', '1697ff579dc29009.jpg');
INSERT INTO `t_sys_file_info` VALUES (817, NULL, NULL, NULL, NULL, '16980115a0729010.png', '16980115a0729010.png');
INSERT INTO `t_sys_file_info` VALUES (818, NULL, NULL, NULL, NULL, '16980139e7a29012.png', '16980139e7a29012.png');
INSERT INTO `t_sys_file_info` VALUES (819, NULL, NULL, NULL, NULL, '169808b140829026.png', '169808b140829026.png');
INSERT INTO `t_sys_file_info` VALUES (820, NULL, NULL, NULL, NULL, '169809e7b2b29030.jpeg', '169809e7b2b29030.jpeg');
INSERT INTO `t_sys_file_info` VALUES (821, NULL, NULL, NULL, NULL, '16980a8c6c629034.jpg', '16980a8c6c629034.jpg');
INSERT INTO `t_sys_file_info` VALUES (822, NULL, NULL, NULL, NULL, '16980f503f529053.jpg', '16980f503f529053.jpg');
INSERT INTO `t_sys_file_info` VALUES (823, NULL, NULL, NULL, NULL, '16981c1ac4a29057.jpeg', '16981c1ac4a29057.jpeg');
INSERT INTO `t_sys_file_info` VALUES (824, NULL, NULL, NULL, NULL, '16981c48c2629058.jpeg', '16981c48c2629058.jpeg');
INSERT INTO `t_sys_file_info` VALUES (825, NULL, NULL, NULL, NULL, '16984d26a9b29076.png', '16984d26a9b29076.png');
INSERT INTO `t_sys_file_info` VALUES (826, NULL, NULL, NULL, NULL, '16984d5274b29079.png', '16984d5274b29079.png');
INSERT INTO `t_sys_file_info` VALUES (827, NULL, NULL, NULL, NULL, '1698584cc7929081.png', '1698584cc7929081.png');
INSERT INTO `t_sys_file_info` VALUES (828, NULL, NULL, NULL, NULL, '16985d51a7229113.png', '16985d51a7229113.png');
INSERT INTO `t_sys_file_info` VALUES (829, NULL, NULL, NULL, NULL, '169864ed07229120.jpg', '169864ed07229120.jpg');
INSERT INTO `t_sys_file_info` VALUES (830, NULL, NULL, NULL, NULL, '169869d87a129127.jpg', '169869d87a129127.jpg');
INSERT INTO `t_sys_file_info` VALUES (831, NULL, NULL, NULL, NULL, '169869e352629129.jpg', '169869e352629129.jpg');
INSERT INTO `t_sys_file_info` VALUES (832, NULL, NULL, NULL, NULL, '16986b0704329131.png', '16986b0704329131.png');
INSERT INTO `t_sys_file_info` VALUES (833, NULL, NULL, NULL, NULL, '16986d909d529132.jpg', '16986d909d529132.jpg');
INSERT INTO `t_sys_file_info` VALUES (834, NULL, NULL, NULL, NULL, '1698744486f29134.jpg', '1698744486f29134.jpg');
INSERT INTO `t_sys_file_info` VALUES (835, NULL, NULL, NULL, NULL, '16989ceada529146.jpg', '16989ceada529146.jpg');
INSERT INTO `t_sys_file_info` VALUES (836, NULL, NULL, NULL, NULL, '16989cfa64d29149.jpg', '16989cfa64d29149.jpg');
INSERT INTO `t_sys_file_info` VALUES (837, NULL, NULL, NULL, NULL, '1698a3a4aed29150.jpg', '1698a3a4aed29150.jpg');
INSERT INTO `t_sys_file_info` VALUES (838, NULL, NULL, NULL, NULL, '1698b06324b29166.jpg', '1698b06324b29166.jpg');
INSERT INTO `t_sys_file_info` VALUES (839, NULL, NULL, NULL, NULL, '1698b94d77729171.jpg', '1698b94d77729171.jpg');
INSERT INTO `t_sys_file_info` VALUES (840, NULL, NULL, NULL, NULL, '1698b9774ba29172.jpg', '1698b9774ba29172.jpg');
INSERT INTO `t_sys_file_info` VALUES (841, NULL, NULL, NULL, NULL, '1698b981d6729173.jpg', '1698b981d6729173.jpg');
INSERT INTO `t_sys_file_info` VALUES (842, NULL, NULL, NULL, NULL, '1698e8b0bca29186.jpg', '1698e8b0bca29186.jpg');
INSERT INTO `t_sys_file_info` VALUES (843, NULL, NULL, NULL, NULL, '1698ecbeca529194.png', '1698ecbeca529194.png');
INSERT INTO `t_sys_file_info` VALUES (844, NULL, NULL, NULL, NULL, '1698ecd1c5229195.png', '1698ecd1c5229195.png');
INSERT INTO `t_sys_file_info` VALUES (845, NULL, NULL, NULL, NULL, '1698ed0cd8829196.png', '1698ed0cd8829196.png');
INSERT INTO `t_sys_file_info` VALUES (846, NULL, NULL, NULL, NULL, '1698f0af18829198.png', '1698f0af18829198.png');
INSERT INTO `t_sys_file_info` VALUES (847, NULL, NULL, NULL, NULL, '1698f5fa38829200.jpg', '1698f5fa38829200.jpg');
INSERT INTO `t_sys_file_info` VALUES (848, NULL, NULL, NULL, NULL, '1698f9dd9ab29210.png', '1698f9dd9ab29210.png');
INSERT INTO `t_sys_file_info` VALUES (849, NULL, NULL, NULL, NULL, '1698f9e6ed529211.png', '1698f9e6ed529211.png');
INSERT INTO `t_sys_file_info` VALUES (850, NULL, NULL, NULL, NULL, '1698fbbc88429221.png', '1698fbbc88429221.png');
INSERT INTO `t_sys_file_info` VALUES (851, NULL, NULL, NULL, NULL, '1698fc0e42329222.png', '1698fc0e42329222.png');
INSERT INTO `t_sys_file_info` VALUES (852, NULL, NULL, NULL, NULL, '1698fc81f6d29225.jpg', '1698fc81f6d29225.jpg');
INSERT INTO `t_sys_file_info` VALUES (853, NULL, NULL, NULL, NULL, '16990d7820129278.jpeg', '16990d7820129278.jpeg');
INSERT INTO `t_sys_file_info` VALUES (854, NULL, NULL, NULL, NULL, '16993fae94229293.png', '16993fae94229293.png');
INSERT INTO `t_sys_file_info` VALUES (855, NULL, NULL, NULL, NULL, '16994a6439929305.png', '16994a6439929305.png');
INSERT INTO `t_sys_file_info` VALUES (856, NULL, NULL, NULL, NULL, '16994d1febb29311.jpg', '16994d1febb29311.jpg');
INSERT INTO `t_sys_file_info` VALUES (857, NULL, NULL, NULL, NULL, '16994e6c99029312.jpg', '16994e6c99029312.jpg');
INSERT INTO `t_sys_file_info` VALUES (858, NULL, NULL, NULL, NULL, '16994e875e729315.jpg', '16994e875e729315.jpg');
INSERT INTO `t_sys_file_info` VALUES (859, NULL, NULL, NULL, NULL, '16994f3a5a629316.jpg', '16994f3a5a629316.jpg');
INSERT INTO `t_sys_file_info` VALUES (860, NULL, NULL, NULL, NULL, '16994fb75d329318.jpg', '16994fb75d329318.jpg');
INSERT INTO `t_sys_file_info` VALUES (861, NULL, NULL, NULL, NULL, '169952bf22a29325.jpg', '169952bf22a29325.jpg');
INSERT INTO `t_sys_file_info` VALUES (862, NULL, NULL, NULL, NULL, '169954052e429327.jpeg', '169954052e429327.jpeg');
INSERT INTO `t_sys_file_info` VALUES (863, NULL, NULL, NULL, NULL, '169955cdfe829341.png', '169955cdfe829341.png');
INSERT INTO `t_sys_file_info` VALUES (864, NULL, NULL, NULL, NULL, '169956e64e629342.jpg', '169956e64e629342.jpg');
INSERT INTO `t_sys_file_info` VALUES (865, NULL, NULL, NULL, NULL, '1699665d1b729357.jpg', '1699665d1b729357.jpg');
INSERT INTO `t_sys_file_info` VALUES (866, NULL, NULL, NULL, NULL, '1699913879a29390.jpg', '1699913879a29390.jpg');
INSERT INTO `t_sys_file_info` VALUES (867, NULL, NULL, NULL, NULL, '1699999b15729392.jpg', '1699999b15729392.jpg');
INSERT INTO `t_sys_file_info` VALUES (868, NULL, NULL, NULL, NULL, '169999f728129398.jpg', '169999f728129398.jpg');
INSERT INTO `t_sys_file_info` VALUES (869, NULL, NULL, NULL, NULL, '1699a1a174129406.jpg', '1699a1a174129406.jpg');
INSERT INTO `t_sys_file_info` VALUES (870, NULL, NULL, NULL, NULL, '1699a22502729408.png', '1699a22502729408.png');
INSERT INTO `t_sys_file_info` VALUES (871, NULL, NULL, NULL, NULL, '1699a8981a329419.png', '1699a8981a329419.png');
INSERT INTO `t_sys_file_info` VALUES (872, NULL, NULL, NULL, NULL, '1699de6045b29431.jpg', '1699de6045b29431.jpg');
INSERT INTO `t_sys_file_info` VALUES (873, NULL, NULL, NULL, NULL, '1699e3cd4ec29447.jpg', '1699e3cd4ec29447.jpg');
INSERT INTO `t_sys_file_info` VALUES (874, NULL, NULL, NULL, NULL, '1699e99bf7729456.jpg', '1699e99bf7729456.jpg');
INSERT INTO `t_sys_file_info` VALUES (875, NULL, NULL, NULL, NULL, '1699ed4179729459.jpg', '1699ed4179729459.jpg');
INSERT INTO `t_sys_file_info` VALUES (876, NULL, NULL, NULL, NULL, '1699f8b942729480.png', '1699f8b942729480.png');
INSERT INTO `t_sys_file_info` VALUES (877, NULL, NULL, NULL, NULL, '1699fb110f929502.jpg', '1699fb110f929502.jpg');
INSERT INTO `t_sys_file_info` VALUES (878, NULL, NULL, NULL, NULL, '169a0cbbe1729516.jpg', '169a0cbbe1729516.jpg');
INSERT INTO `t_sys_file_info` VALUES (879, NULL, NULL, NULL, NULL, '169a0cccd1d29517.jpg', '169a0cccd1d29517.jpg');
INSERT INTO `t_sys_file_info` VALUES (880, NULL, NULL, NULL, NULL, '169a0cd6af729518.jpg', '169a0cd6af729518.jpg');
INSERT INTO `t_sys_file_info` VALUES (881, NULL, NULL, NULL, NULL, '169a315471129528.jpg', '169a315471129528.jpg');
INSERT INTO `t_sys_file_info` VALUES (882, NULL, NULL, NULL, NULL, '169a358910829544.png', '169a358910829544.png');
INSERT INTO `t_sys_file_info` VALUES (883, NULL, NULL, NULL, NULL, '169a635179229607.png', '169a635179229607.png');
INSERT INTO `t_sys_file_info` VALUES (884, NULL, NULL, NULL, NULL, '169a9c84f0c29617.png', '169a9c84f0c29617.png');
INSERT INTO `t_sys_file_info` VALUES (885, NULL, NULL, NULL, NULL, '169a9e860a629618.png', '169a9e860a629618.png');
INSERT INTO `t_sys_file_info` VALUES (886, NULL, NULL, NULL, NULL, '169aa10848929620.png', '169aa10848929620.png');
INSERT INTO `t_sys_file_info` VALUES (887, NULL, NULL, NULL, NULL, '169aa632b2329621.jpg', '169aa632b2329621.jpg');
INSERT INTO `t_sys_file_info` VALUES (888, NULL, NULL, NULL, NULL, '169ab0a9ddf29624.png', '169ab0a9ddf29624.png');
INSERT INTO `t_sys_file_info` VALUES (889, NULL, NULL, NULL, NULL, '169add5f3cb29636.jpg', '169add5f3cb29636.jpg');
INSERT INTO `t_sys_file_info` VALUES (890, NULL, NULL, NULL, NULL, '169adda03bd29637.jpg', '169adda03bd29637.jpg');
INSERT INTO `t_sys_file_info` VALUES (891, NULL, NULL, NULL, NULL, '169addaa98429638.jpg', '169addaa98429638.jpg');
INSERT INTO `t_sys_file_info` VALUES (892, NULL, NULL, NULL, NULL, '169aef8f52a29649.jpg', '169aef8f52a29649.jpg');
INSERT INTO `t_sys_file_info` VALUES (893, NULL, NULL, NULL, NULL, '169aef99d2829650.jpg', '169aef99d2829650.jpg');
INSERT INTO `t_sys_file_info` VALUES (894, NULL, NULL, NULL, NULL, '169aeffe61629651.png', '169aeffe61629651.png');
INSERT INTO `t_sys_file_info` VALUES (895, NULL, NULL, NULL, NULL, '169b274689729668.jpg', '169b274689729668.jpg');
INSERT INTO `t_sys_file_info` VALUES (896, NULL, NULL, NULL, NULL, '169b27530ca29670.jpg', '169b27530ca29670.jpg');
INSERT INTO `t_sys_file_info` VALUES (897, NULL, NULL, NULL, NULL, '169b27f5e8e29674.jpeg', '169b27f5e8e29674.jpeg');
INSERT INTO `t_sys_file_info` VALUES (898, NULL, NULL, NULL, NULL, '169b288910329675.jpg', '169b288910329675.jpg');
INSERT INTO `t_sys_file_info` VALUES (899, NULL, NULL, NULL, NULL, '169b2935cc729676.jpg', '169b2935cc729676.jpg');
INSERT INTO `t_sys_file_info` VALUES (900, NULL, NULL, NULL, NULL, '169b2af05e429677.png', '169b2af05e429677.png');
INSERT INTO `t_sys_file_info` VALUES (901, NULL, NULL, NULL, NULL, '169b328521729704.jpeg', '169b328521729704.jpeg');
INSERT INTO `t_sys_file_info` VALUES (902, NULL, NULL, NULL, NULL, '169b3533a0a29705.jpg', '169b3533a0a29705.jpg');
INSERT INTO `t_sys_file_info` VALUES (903, NULL, NULL, NULL, NULL, '169b3bfd9d329726.jpg', '169b3bfd9d329726.jpg');
INSERT INTO `t_sys_file_info` VALUES (904, NULL, NULL, NULL, NULL, '169b462742729750.png', '169b462742729750.png');
INSERT INTO `t_sys_file_info` VALUES (905, NULL, NULL, NULL, NULL, '169b48d513729758.jpg', '169b48d513729758.jpg');
INSERT INTO `t_sys_file_info` VALUES (906, NULL, NULL, NULL, NULL, '169b4a2625929760.jpg', '169b4a2625929760.jpg');
INSERT INTO `t_sys_file_info` VALUES (907, NULL, NULL, NULL, NULL, '169b4a5029829761.jpg', '169b4a5029829761.jpg');
INSERT INTO `t_sys_file_info` VALUES (908, NULL, NULL, NULL, NULL, '169b59dbe3329767.png', '169b59dbe3329767.png');
INSERT INTO `t_sys_file_info` VALUES (909, NULL, NULL, NULL, NULL, '169b7e2f32129773.jpg', '169b7e2f32129773.jpg');
INSERT INTO `t_sys_file_info` VALUES (910, NULL, NULL, NULL, NULL, '169b883cd6029779.png', '169b883cd6029779.png');
INSERT INTO `t_sys_file_info` VALUES (911, NULL, NULL, NULL, NULL, '169b88495f129781.png', '169b88495f129781.png');
INSERT INTO `t_sys_file_info` VALUES (912, NULL, NULL, NULL, NULL, '169b8cfa85e29791.jpg', '169b8cfa85e29791.jpg');
INSERT INTO `t_sys_file_info` VALUES (913, NULL, NULL, NULL, NULL, '169b8d09ba429792.jpg', '169b8d09ba429792.jpg');
INSERT INTO `t_sys_file_info` VALUES (914, NULL, NULL, NULL, NULL, '169b8d2863929794.jpg', '169b8d2863929794.jpg');
INSERT INTO `t_sys_file_info` VALUES (915, NULL, NULL, NULL, NULL, '169b8d9625f29795.jpg', '169b8d9625f29795.jpg');
INSERT INTO `t_sys_file_info` VALUES (916, NULL, NULL, NULL, NULL, '169b8eff38e29796.jpg', '169b8eff38e29796.jpg');
INSERT INTO `t_sys_file_info` VALUES (917, NULL, NULL, NULL, NULL, '169b91054e229801.jpg', '169b91054e229801.jpg');
INSERT INTO `t_sys_file_info` VALUES (918, NULL, NULL, NULL, NULL, '169b922671c29803.jpg', '169b922671c29803.jpg');
INSERT INTO `t_sys_file_info` VALUES (919, NULL, NULL, NULL, NULL, '169b9e43b9329820.jpg', '169b9e43b9329820.jpg');
INSERT INTO `t_sys_file_info` VALUES (920, NULL, NULL, NULL, NULL, '169bcdddd8129838.png', '169bcdddd8129838.png');
INSERT INTO `t_sys_file_info` VALUES (921, NULL, NULL, NULL, NULL, '169bd8be8f229847.jpg', '169bd8be8f229847.jpg');
INSERT INTO `t_sys_file_info` VALUES (922, NULL, NULL, NULL, NULL, '169bd8faabf29850.jpg', '169bd8faabf29850.jpg');
INSERT INTO `t_sys_file_info` VALUES (923, NULL, NULL, NULL, NULL, '169bd9120ef29851.jpg', '169bd9120ef29851.jpg');
INSERT INTO `t_sys_file_info` VALUES (924, NULL, NULL, NULL, NULL, '169bdd662bb29860.jpg', '169bdd662bb29860.jpg');
INSERT INTO `t_sys_file_info` VALUES (925, NULL, NULL, NULL, NULL, '169bddcd72729861.jpg', '169bddcd72729861.jpg');
INSERT INTO `t_sys_file_info` VALUES (926, NULL, NULL, NULL, NULL, '169be19846729868.jpeg', '169be19846729868.jpeg');
INSERT INTO `t_sys_file_info` VALUES (927, NULL, NULL, NULL, NULL, '169be3cb68729875.jpg', '169be3cb68729875.jpg');
INSERT INTO `t_sys_file_info` VALUES (928, NULL, NULL, NULL, NULL, '169be706d6929883.jpg', '169be706d6929883.jpg');
INSERT INTO `t_sys_file_info` VALUES (929, NULL, NULL, NULL, NULL, '169be71e6b129884.png', '169be71e6b129884.png');
INSERT INTO `t_sys_file_info` VALUES (930, NULL, NULL, NULL, NULL, '169be77a3e929885.jpg', '169be77a3e929885.jpg');
INSERT INTO `t_sys_file_info` VALUES (931, NULL, NULL, NULL, NULL, '169be7d77a929886.jpg', '169be7d77a929886.jpg');
INSERT INTO `t_sys_file_info` VALUES (932, NULL, NULL, NULL, NULL, '169be9ae20829892.png', '169be9ae20829892.png');
INSERT INTO `t_sys_file_info` VALUES (933, NULL, NULL, NULL, NULL, '169bf177fda29902.jpg', '169bf177fda29902.jpg');
INSERT INTO `t_sys_file_info` VALUES (934, NULL, NULL, NULL, NULL, '169bf57621729904.jpg', '169bf57621729904.jpg');
INSERT INTO `t_sys_file_info` VALUES (935, NULL, NULL, NULL, NULL, '169c2458cbb29933.jpg', '169c2458cbb29933.jpg');
INSERT INTO `t_sys_file_info` VALUES (936, NULL, NULL, NULL, NULL, '169c333aae929950.jpg', '169c333aae929950.jpg');
INSERT INTO `t_sys_file_info` VALUES (937, NULL, NULL, NULL, NULL, '169c38e7d5729972.jpg', '169c38e7d5729972.jpg');
INSERT INTO `t_sys_file_info` VALUES (938, NULL, NULL, NULL, NULL, '169c3a2579029985.jpg', '169c3a2579029985.jpg');
INSERT INTO `t_sys_file_info` VALUES (939, NULL, NULL, NULL, NULL, '169c3be741729988.jpg', '169c3be741729988.jpg');
INSERT INTO `t_sys_file_info` VALUES (940, NULL, NULL, NULL, NULL, '169c3bf989d29989.jpg', '169c3bf989d29989.jpg');
INSERT INTO `t_sys_file_info` VALUES (941, NULL, NULL, NULL, NULL, '169c3bfff5529990.jpg', '169c3bfff5529990.jpg');
INSERT INTO `t_sys_file_info` VALUES (942, NULL, NULL, NULL, NULL, '169c3c0b95029991.jpg', '169c3c0b95029991.jpg');
INSERT INTO `t_sys_file_info` VALUES (943, NULL, NULL, NULL, NULL, '169c3c1da6829992.jpg', '169c3c1da6829992.jpg');
INSERT INTO `t_sys_file_info` VALUES (944, NULL, NULL, NULL, NULL, '169c3ece95230003.jpg', '169c3ece95230003.jpg');
INSERT INTO `t_sys_file_info` VALUES (945, NULL, NULL, NULL, NULL, '169c3ee714930006.jpg', '169c3ee714930006.jpg');
INSERT INTO `t_sys_file_info` VALUES (946, NULL, NULL, NULL, NULL, '169c4a383e230024.png', '169c4a383e230024.png');
INSERT INTO `t_sys_file_info` VALUES (947, NULL, NULL, NULL, NULL, '169c75ff02030042.jpg', '169c75ff02030042.jpg');
INSERT INTO `t_sys_file_info` VALUES (948, NULL, NULL, NULL, NULL, '169c7e34f7730054.png', '169c7e34f7730054.png');
INSERT INTO `t_sys_file_info` VALUES (949, NULL, NULL, NULL, NULL, '169c81af3b530061.jpg', '169c81af3b530061.jpg');
INSERT INTO `t_sys_file_info` VALUES (950, NULL, NULL, NULL, NULL, '169c8276d5730064.jpg', '169c8276d5730064.jpg');
INSERT INTO `t_sys_file_info` VALUES (951, NULL, NULL, NULL, NULL, '169c828963230065.jpg', '169c828963230065.jpg');
INSERT INTO `t_sys_file_info` VALUES (952, NULL, NULL, NULL, NULL, '169c836f21d30069.jpg', '169c836f21d30069.jpg');
INSERT INTO `t_sys_file_info` VALUES (953, NULL, NULL, NULL, NULL, '169c852934730074.jpg', '169c852934730074.jpg');
INSERT INTO `t_sys_file_info` VALUES (954, NULL, NULL, NULL, NULL, '169c8563b8930075.jpg', '169c8563b8930075.jpg');
INSERT INTO `t_sys_file_info` VALUES (955, NULL, NULL, NULL, NULL, '169c859f41630076.jpg', '169c859f41630076.jpg');
INSERT INTO `t_sys_file_info` VALUES (956, NULL, NULL, NULL, NULL, '169c86bac6c30077.jpg', '169c86bac6c30077.jpg');
INSERT INTO `t_sys_file_info` VALUES (957, NULL, NULL, NULL, NULL, '169c86dbc6a30078.png', '169c86dbc6a30078.png');
INSERT INTO `t_sys_file_info` VALUES (958, NULL, NULL, NULL, NULL, '169c8775efc30079.jpg', '169c8775efc30079.jpg');
INSERT INTO `t_sys_file_info` VALUES (959, NULL, NULL, NULL, NULL, '169c88224f030081.jpg', '169c88224f030081.jpg');
INSERT INTO `t_sys_file_info` VALUES (960, NULL, NULL, NULL, NULL, '169c884017c30083.jpg', '169c884017c30083.jpg');
INSERT INTO `t_sys_file_info` VALUES (961, NULL, NULL, NULL, NULL, '169c88986b830088.jpg', '169c88986b830088.jpg');
INSERT INTO `t_sys_file_info` VALUES (962, NULL, NULL, NULL, NULL, '169c88a602730089.jpg', '169c88a602730089.jpg');
INSERT INTO `t_sys_file_info` VALUES (963, NULL, NULL, NULL, NULL, '169c88b7abe30090.jpg', '169c88b7abe30090.jpg');
INSERT INTO `t_sys_file_info` VALUES (964, NULL, NULL, NULL, NULL, '169c88e844230091.jpg', '169c88e844230091.jpg');
INSERT INTO `t_sys_file_info` VALUES (965, NULL, NULL, NULL, NULL, '169c890405f30092.jpg', '169c890405f30092.jpg');
INSERT INTO `t_sys_file_info` VALUES (966, NULL, NULL, NULL, NULL, '169c8bfec5430100.jpg', '169c8bfec5430100.jpg');
INSERT INTO `t_sys_file_info` VALUES (967, NULL, NULL, NULL, NULL, '169cc2adb4b30107.jpg', '169cc2adb4b30107.jpg');
INSERT INTO `t_sys_file_info` VALUES (968, NULL, NULL, NULL, NULL, '169cc2ec8ae30111.jpg', '169cc2ec8ae30111.jpg');
INSERT INTO `t_sys_file_info` VALUES (969, NULL, NULL, NULL, NULL, '169d27cea5530134.jpg', '169d27cea5530134.jpg');
INSERT INTO `t_sys_file_info` VALUES (970, NULL, NULL, NULL, NULL, '169d32e30e830143.jpg', '169d32e30e830143.jpg');
INSERT INTO `t_sys_file_info` VALUES (971, NULL, NULL, NULL, NULL, '169d32eea3530145.jpg', '169d32eea3530145.jpg');
INSERT INTO `t_sys_file_info` VALUES (972, NULL, NULL, NULL, NULL, '169d33444c430150.jpg', '169d33444c430150.jpg');
INSERT INTO `t_sys_file_info` VALUES (973, NULL, NULL, NULL, NULL, '169d33f8a6230151.jpg', '169d33f8a6230151.jpg');
INSERT INTO `t_sys_file_info` VALUES (974, NULL, NULL, NULL, NULL, '169d3937fe330156.jpg', '169d3937fe330156.jpg');
INSERT INTO `t_sys_file_info` VALUES (975, NULL, NULL, NULL, NULL, '169d39705b230157.jpg', '169d39705b230157.jpg');
INSERT INTO `t_sys_file_info` VALUES (976, NULL, NULL, NULL, NULL, '169d39bcfbc30160.jpg', '169d39bcfbc30160.jpg');
INSERT INTO `t_sys_file_info` VALUES (977, NULL, NULL, NULL, NULL, '169d459d4ae30164.jpg', '169d459d4ae30164.jpg');
INSERT INTO `t_sys_file_info` VALUES (978, NULL, NULL, NULL, NULL, '169d461a73a30166.png', '169d461a73a30166.png');
INSERT INTO `t_sys_file_info` VALUES (979, NULL, NULL, NULL, NULL, '169d70a794d30181.jpg', '169d70a794d30181.jpg');
INSERT INTO `t_sys_file_info` VALUES (980, NULL, NULL, NULL, NULL, '169d70ad8bd30182.jpg', '169d70ad8bd30182.jpg');
INSERT INTO `t_sys_file_info` VALUES (981, NULL, NULL, NULL, NULL, '169d754988130186.jpg', '169d754988130186.jpg');
INSERT INTO `t_sys_file_info` VALUES (982, NULL, NULL, NULL, NULL, '169d79c500530191.jpeg', '169d79c500530191.jpeg');
INSERT INTO `t_sys_file_info` VALUES (983, NULL, NULL, NULL, NULL, '169d7a2d43b30192.png', '169d7a2d43b30192.png');
INSERT INTO `t_sys_file_info` VALUES (984, NULL, NULL, NULL, NULL, '169d7c30cb130196.jpg', '169d7c30cb130196.jpg');
INSERT INTO `t_sys_file_info` VALUES (985, NULL, NULL, NULL, NULL, '169d7c6371730199.jpg', '169d7c6371730199.jpg');
INSERT INTO `t_sys_file_info` VALUES (986, NULL, NULL, NULL, NULL, '169d7c7efe530200.png', '169d7c7efe530200.png');
INSERT INTO `t_sys_file_info` VALUES (987, NULL, NULL, NULL, NULL, '169d849d3c330218.png', '169d849d3c330218.png');
INSERT INTO `t_sys_file_info` VALUES (988, NULL, NULL, NULL, NULL, '169d862edd930223.jpg', '169d862edd930223.jpg');
INSERT INTO `t_sys_file_info` VALUES (989, NULL, NULL, NULL, NULL, '169d894d2e630226.jpg', '169d894d2e630226.jpg');
INSERT INTO `t_sys_file_info` VALUES (990, NULL, NULL, NULL, NULL, '169d8fb231530234.jpg', '169d8fb231530234.jpg');
INSERT INTO `t_sys_file_info` VALUES (991, NULL, NULL, NULL, NULL, '169d98f193430239.jpg', '169d98f193430239.jpg');
INSERT INTO `t_sys_file_info` VALUES (992, NULL, NULL, NULL, NULL, '169d990991030242.jpg', '169d990991030242.jpg');
INSERT INTO `t_sys_file_info` VALUES (993, NULL, NULL, NULL, NULL, '169dbe5005830259.png', '169dbe5005830259.png');
INSERT INTO `t_sys_file_info` VALUES (994, NULL, NULL, NULL, NULL, '169dbe8f73c30260.png', '169dbe8f73c30260.png');
INSERT INTO `t_sys_file_info` VALUES (995, NULL, NULL, NULL, NULL, '169dc38cebe30265.jpg', '169dc38cebe30265.jpg');
INSERT INTO `t_sys_file_info` VALUES (996, NULL, NULL, NULL, NULL, '169dcce80de30277.png', '169dcce80de30277.png');
INSERT INTO `t_sys_file_info` VALUES (997, NULL, NULL, NULL, NULL, '169dcd2afbf30282.jpg', '169dcd2afbf30282.jpg');
INSERT INTO `t_sys_file_info` VALUES (998, NULL, NULL, NULL, NULL, '169dd3c669730295.jpg', '169dd3c669730295.jpg');
INSERT INTO `t_sys_file_info` VALUES (999, NULL, NULL, NULL, NULL, '169dd3cc4c130296.jpg', '169dd3cc4c130296.jpg');
INSERT INTO `t_sys_file_info` VALUES (1000, NULL, NULL, NULL, NULL, '169dd55fd2130307.png', '169dd55fd2130307.png');
INSERT INTO `t_sys_file_info` VALUES (1001, NULL, NULL, NULL, NULL, '169dd5758ce30311.png', '169dd5758ce30311.png');
INSERT INTO `t_sys_file_info` VALUES (1002, NULL, NULL, NULL, NULL, '169dd912b8e30328.jpg', '169dd912b8e30328.jpg');
INSERT INTO `t_sys_file_info` VALUES (1003, NULL, NULL, NULL, NULL, '169de001c6530345.jpg', '169de001c6530345.jpg');
INSERT INTO `t_sys_file_info` VALUES (1004, NULL, NULL, NULL, NULL, '169de2e0fdd30347.png', '169de2e0fdd30347.png');
INSERT INTO `t_sys_file_info` VALUES (1005, NULL, NULL, NULL, NULL, '169de7dd22a30353.png', '169de7dd22a30353.png');
INSERT INTO `t_sys_file_info` VALUES (1006, NULL, NULL, NULL, NULL, '169de7e77ca30357.png', '169de7e77ca30357.png');
INSERT INTO `t_sys_file_info` VALUES (1007, NULL, NULL, NULL, NULL, '169df3e76ca30360.png', '169df3e76ca30360.png');
INSERT INTO `t_sys_file_info` VALUES (1008, NULL, NULL, NULL, NULL, '169e0f0072b30368.png', '169e0f0072b30368.png');
INSERT INTO `t_sys_file_info` VALUES (1009, NULL, NULL, NULL, NULL, '169e139dc8730376.jpg', '169e139dc8730376.jpg');
INSERT INTO `t_sys_file_info` VALUES (1010, NULL, NULL, NULL, NULL, '169e13b15c230379.jpg', '169e13b15c230379.jpg');
INSERT INTO `t_sys_file_info` VALUES (1011, NULL, NULL, NULL, NULL, '169e1664c5230382.jpg', '169e1664c5230382.jpg');
INSERT INTO `t_sys_file_info` VALUES (1012, NULL, NULL, NULL, NULL, '169e1c1135730389.jpg', '169e1c1135730389.jpg');
INSERT INTO `t_sys_file_info` VALUES (1013, NULL, NULL, NULL, NULL, '169e1c17e5f30390.jpg', '169e1c17e5f30390.jpg');
INSERT INTO `t_sys_file_info` VALUES (1014, NULL, NULL, NULL, NULL, '169e29768f230401.jpg', '169e29768f230401.jpg');
INSERT INTO `t_sys_file_info` VALUES (1015, NULL, NULL, NULL, NULL, '169e2df6a3c30407.png', '169e2df6a3c30407.png');
INSERT INTO `t_sys_file_info` VALUES (1016, NULL, NULL, NULL, NULL, '169e3971d7c30412.jpg', '169e3971d7c30412.jpg');
INSERT INTO `t_sys_file_info` VALUES (1017, NULL, NULL, NULL, NULL, '169e5d937e430418.jpg', '169e5d937e430418.jpg');
INSERT INTO `t_sys_file_info` VALUES (1018, NULL, NULL, NULL, NULL, '169e7083feb30439.png', '169e7083feb30439.png');
INSERT INTO `t_sys_file_info` VALUES (1019, NULL, NULL, NULL, NULL, '169e79ea48d30455.jpg', '169e79ea48d30455.jpg');
INSERT INTO `t_sys_file_info` VALUES (1020, NULL, NULL, NULL, NULL, '169e79f7d3e30456.jpg', '169e79f7d3e30456.jpg');
INSERT INTO `t_sys_file_info` VALUES (1021, NULL, NULL, NULL, NULL, '169e7a6b6d530457.jpg', '169e7a6b6d530457.jpg');
INSERT INTO `t_sys_file_info` VALUES (1022, NULL, NULL, NULL, NULL, '169e871e5a630460.jpg', '169e871e5a630460.jpg');
INSERT INTO `t_sys_file_info` VALUES (1023, NULL, NULL, NULL, NULL, '169e883aa4230464.jpg', '169e883aa4230464.jpg');
INSERT INTO `t_sys_file_info` VALUES (1024, NULL, NULL, NULL, NULL, '169ebe1547930470.jpg', '169ebe1547930470.jpg');
INSERT INTO `t_sys_file_info` VALUES (1025, NULL, NULL, NULL, NULL, '169ed37328b30477.png', '169ed37328b30477.png');
INSERT INTO `t_sys_file_info` VALUES (1026, NULL, NULL, NULL, NULL, '169f2f13b2330485.jpg', '169f2f13b2330485.jpg');
INSERT INTO `t_sys_file_info` VALUES (1027, NULL, NULL, NULL, NULL, '169f2f181ac30486.jpg', '169f2f181ac30486.jpg');
INSERT INTO `t_sys_file_info` VALUES (1028, NULL, NULL, NULL, NULL, '169f2fd358e30488.jpg', '169f2fd358e30488.jpg');
INSERT INTO `t_sys_file_info` VALUES (1029, NULL, NULL, NULL, NULL, '169f73f0e8d30506.jpg', '169f73f0e8d30506.jpg');
INSERT INTO `t_sys_file_info` VALUES (1030, NULL, NULL, NULL, NULL, '169fa64c1b030518.jpg', '169fa64c1b030518.jpg');
INSERT INTO `t_sys_file_info` VALUES (1031, NULL, NULL, NULL, NULL, '169fab39dd030519.jpg', '169fab39dd030519.jpg');
INSERT INTO `t_sys_file_info` VALUES (1032, NULL, NULL, NULL, NULL, '169fab49f2730521.jpg', '169fab49f2730521.jpg');
INSERT INTO `t_sys_file_info` VALUES (1033, NULL, NULL, NULL, NULL, '169facf677930529.jpg', '169facf677930529.jpg');
INSERT INTO `t_sys_file_info` VALUES (1034, NULL, NULL, NULL, NULL, '169fb8115e630546.jpg', '169fb8115e630546.jpg');
INSERT INTO `t_sys_file_info` VALUES (1035, NULL, NULL, NULL, NULL, '169fb9e4aaf30553.png', '169fb9e4aaf30553.png');
INSERT INTO `t_sys_file_info` VALUES (1036, NULL, NULL, NULL, NULL, '169fba7824030555.png', '169fba7824030555.png');
INSERT INTO `t_sys_file_info` VALUES (1037, NULL, NULL, NULL, NULL, '169fbeedc2630568.jpg', '169fbeedc2630568.jpg');
INSERT INTO `t_sys_file_info` VALUES (1038, NULL, NULL, NULL, NULL, '169fbf7724830570.png', '169fbf7724830570.png');
INSERT INTO `t_sys_file_info` VALUES (1039, NULL, NULL, NULL, NULL, '169fbfadaa430571.png', '169fbfadaa430571.png');
INSERT INTO `t_sys_file_info` VALUES (1040, NULL, NULL, NULL, NULL, '169fffef8b130595.jpg', '169fffef8b130595.jpg');
INSERT INTO `t_sys_file_info` VALUES (1041, NULL, NULL, NULL, NULL, '16a00d48b5b30636.jpg', '16a00d48b5b30636.jpg');
INSERT INTO `t_sys_file_info` VALUES (1042, NULL, NULL, NULL, NULL, '16a0142942830656.png', '16a0142942830656.png');
INSERT INTO `t_sys_file_info` VALUES (1043, NULL, NULL, NULL, NULL, '16a0163950e30659.jpg', '16a0163950e30659.jpg');
INSERT INTO `t_sys_file_info` VALUES (1044, NULL, NULL, NULL, NULL, '16a01e0abca30665.jpg', '16a01e0abca30665.jpg');
INSERT INTO `t_sys_file_info` VALUES (1045, NULL, NULL, NULL, NULL, '16a025ebe3830675.jpg', '16a025ebe3830675.jpg');
INSERT INTO `t_sys_file_info` VALUES (1046, NULL, NULL, NULL, NULL, '16a0260114b30676.png', '16a0260114b30676.png');
INSERT INTO `t_sys_file_info` VALUES (1047, NULL, NULL, NULL, NULL, '16a0264259530677.png', '16a0264259530677.png');
INSERT INTO `t_sys_file_info` VALUES (1048, NULL, NULL, NULL, NULL, '16a04b903f130680.jpg', '16a04b903f130680.jpg');
INSERT INTO `t_sys_file_info` VALUES (1049, NULL, NULL, NULL, NULL, '16a04febbaa30689.png', '16a04febbaa30689.png');
INSERT INTO `t_sys_file_info` VALUES (1050, NULL, NULL, NULL, NULL, '16a05f7c16e30718.png', '16a05f7c16e30718.png');
INSERT INTO `t_sys_file_info` VALUES (1051, NULL, NULL, NULL, NULL, '16a06157afd30723.png', '16a06157afd30723.png');
INSERT INTO `t_sys_file_info` VALUES (1052, NULL, NULL, NULL, NULL, '16a0af0bc8d30814.png', '16a0af0bc8d30814.png');
INSERT INTO `t_sys_file_info` VALUES (1053, NULL, NULL, NULL, NULL, '16a0b6c191530832.jpg', '16a0b6c191530832.jpg');
INSERT INTO `t_sys_file_info` VALUES (1054, NULL, NULL, NULL, NULL, '16a0b70205b30835.jpg', '16a0b70205b30835.jpg');
INSERT INTO `t_sys_file_info` VALUES (1055, NULL, NULL, NULL, NULL, '16a0b8a965d30839.jpg', '16a0b8a965d30839.jpg');
INSERT INTO `t_sys_file_info` VALUES (1056, NULL, NULL, NULL, NULL, '16a0b91b29f30844.jpg', '16a0b91b29f30844.jpg');
INSERT INTO `t_sys_file_info` VALUES (1057, NULL, NULL, NULL, NULL, '16a0bb02e6a30857.jpg', '16a0bb02e6a30857.jpg');
INSERT INTO `t_sys_file_info` VALUES (1058, NULL, NULL, NULL, NULL, '16a0bc09a5a30864.png', '16a0bc09a5a30864.png');
INSERT INTO `t_sys_file_info` VALUES (1059, NULL, NULL, NULL, NULL, '16a0c07c90330867.jpg', '16a0c07c90330867.jpg');
INSERT INTO `t_sys_file_info` VALUES (1060, NULL, NULL, NULL, NULL, '16a0c41682630868.jpg', '16a0c41682630868.jpg');
INSERT INTO `t_sys_file_info` VALUES (1061, NULL, NULL, NULL, NULL, '16a0c99dd6330871.png', '16a0c99dd6330871.png');
INSERT INTO `t_sys_file_info` VALUES (1062, NULL, NULL, NULL, NULL, '16a0f6e1ee630886.jpg', '16a0f6e1ee630886.jpg');
INSERT INTO `t_sys_file_info` VALUES (1063, NULL, NULL, NULL, NULL, '16a0f71a75230889.png', '16a0f71a75230889.png');
INSERT INTO `t_sys_file_info` VALUES (1064, NULL, NULL, NULL, NULL, '16a0f86e8ba30894.png', '16a0f86e8ba30894.png');
INSERT INTO `t_sys_file_info` VALUES (1065, NULL, NULL, NULL, NULL, '16a0f8bf55f30898.jpg', '16a0f8bf55f30898.jpg');
INSERT INTO `t_sys_file_info` VALUES (1066, NULL, NULL, NULL, NULL, '16a0f9f281430906.png', '16a0f9f281430906.png');
INSERT INTO `t_sys_file_info` VALUES (1067, NULL, NULL, NULL, NULL, '16a0fb4006d30908.jpg', '16a0fb4006d30908.jpg');
INSERT INTO `t_sys_file_info` VALUES (1068, NULL, NULL, NULL, NULL, '16a10850cbb30924.png', '16a10850cbb30924.png');
INSERT INTO `t_sys_file_info` VALUES (1069, NULL, NULL, NULL, NULL, '16a10ad39fc30934.jpg', '16a10ad39fc30934.jpg');
INSERT INTO `t_sys_file_info` VALUES (1070, NULL, NULL, NULL, NULL, '16a10ae031330935.jpg', '16a10ae031330935.jpg');
INSERT INTO `t_sys_file_info` VALUES (1071, NULL, NULL, NULL, NULL, '16a116770dc30940.jpg', '16a116770dc30940.jpg');
INSERT INTO `t_sys_file_info` VALUES (1072, NULL, NULL, NULL, NULL, '16a149cd98b30951.jpg', '16a149cd98b30951.jpg');
INSERT INTO `t_sys_file_info` VALUES (1073, NULL, NULL, NULL, NULL, '16a1593f32f30958.png', '16a1593f32f30958.png');
INSERT INTO `t_sys_file_info` VALUES (1074, NULL, NULL, NULL, NULL, '16a1596384230961.png', '16a1596384230961.png');
INSERT INTO `t_sys_file_info` VALUES (1075, NULL, NULL, NULL, NULL, '16a16859d2830987.png', '16a16859d2830987.png');
INSERT INTO `t_sys_file_info` VALUES (1076, NULL, NULL, NULL, NULL, '16a16f0d09430993.jpg', '16a16f0d09430993.jpg');
INSERT INTO `t_sys_file_info` VALUES (1077, NULL, NULL, NULL, NULL, '16a1999a38430995.jpg', '16a1999a38430995.jpg');
INSERT INTO `t_sys_file_info` VALUES (1078, NULL, NULL, NULL, NULL, '16a1afceb6431007.jpg', '16a1afceb6431007.jpg');
INSERT INTO `t_sys_file_info` VALUES (1079, NULL, NULL, NULL, NULL, '16a1afe3fbd31008.jpg', '16a1afe3fbd31008.jpg');
INSERT INTO `t_sys_file_info` VALUES (1080, NULL, NULL, NULL, NULL, '16a1c30b08131015.jpg', '16a1c30b08131015.jpg');
INSERT INTO `t_sys_file_info` VALUES (1081, NULL, NULL, NULL, NULL, '16a1ef5c22731028.png', '16a1ef5c22731028.png');
INSERT INTO `t_sys_file_info` VALUES (1082, NULL, NULL, NULL, NULL, '16a1ef6697131032.png', '16a1ef6697131032.png');
INSERT INTO `t_sys_file_info` VALUES (1083, NULL, NULL, NULL, NULL, '16a1f9c1b3831042.png', '16a1f9c1b3831042.png');
INSERT INTO `t_sys_file_info` VALUES (1084, NULL, NULL, NULL, NULL, '16a1fc00dc831048.jpg', '16a1fc00dc831048.jpg');
INSERT INTO `t_sys_file_info` VALUES (1085, NULL, NULL, NULL, NULL, '16a1fcb59ff31050.jpg', '16a1fcb59ff31050.jpg');
INSERT INTO `t_sys_file_info` VALUES (1086, NULL, NULL, NULL, NULL, '16a201003dd31063.jpg', '16a201003dd31063.jpg');
INSERT INTO `t_sys_file_info` VALUES (1087, NULL, NULL, NULL, NULL, '16a208e189b31081.jpg', '16a208e189b31081.jpg');
INSERT INTO `t_sys_file_info` VALUES (1088, NULL, NULL, NULL, NULL, '16a242c5bc431099.jpg', '16a242c5bc431099.jpg');
INSERT INTO `t_sys_file_info` VALUES (1089, NULL, NULL, NULL, NULL, '16a2537fece31115.jpg', '16a2537fece31115.jpg');
INSERT INTO `t_sys_file_info` VALUES (1090, NULL, NULL, NULL, NULL, '16a25833d2131131.png', '16a25833d2131131.png');
INSERT INTO `t_sys_file_info` VALUES (1091, NULL, NULL, NULL, NULL, '16a25ba92e831136.png', '16a25ba92e831136.png');
INSERT INTO `t_sys_file_info` VALUES (1092, NULL, NULL, NULL, NULL, '16a293ee93531157.jpg', '16a293ee93531157.jpg');
INSERT INTO `t_sys_file_info` VALUES (1093, NULL, NULL, NULL, NULL, '16a295ffbc231166.jpg', '16a295ffbc231166.jpg');
INSERT INTO `t_sys_file_info` VALUES (1094, NULL, NULL, NULL, NULL, '16a2960a00b31170.jpg', '16a2960a00b31170.jpg');
INSERT INTO `t_sys_file_info` VALUES (1095, NULL, NULL, NULL, NULL, '16a296e4d8031176.jpg', '16a296e4d8031176.jpg');
INSERT INTO `t_sys_file_info` VALUES (1096, NULL, NULL, NULL, NULL, '16a2975bf6331177.jpg', '16a2975bf6331177.jpg');
INSERT INTO `t_sys_file_info` VALUES (1097, NULL, NULL, NULL, NULL, '16a297701e231182.jpeg', '16a297701e231182.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1098, NULL, NULL, NULL, NULL, '16a29783d5631183.jpeg', '16a29783d5631183.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1099, NULL, NULL, NULL, NULL, '16a298a5fbd31184.png', '16a298a5fbd31184.png');
INSERT INTO `t_sys_file_info` VALUES (1100, NULL, NULL, NULL, NULL, '16a29da486b31188.jpg', '16a29da486b31188.jpg');
INSERT INTO `t_sys_file_info` VALUES (1101, NULL, NULL, NULL, NULL, '16a29db4e8631189.jpg', '16a29db4e8631189.jpg');
INSERT INTO `t_sys_file_info` VALUES (1102, NULL, NULL, NULL, NULL, '16a29dc61a631190.jpg', '16a29dc61a631190.jpg');
INSERT INTO `t_sys_file_info` VALUES (1103, NULL, NULL, NULL, NULL, '16a29fad1a531200.jpeg', '16a29fad1a531200.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1104, NULL, NULL, NULL, NULL, '16a2a1dbd8a31206.jpg', '16a2a1dbd8a31206.jpg');
INSERT INTO `t_sys_file_info` VALUES (1105, NULL, NULL, NULL, NULL, '16a2b4d796331226.jpg', '16a2b4d796331226.jpg');
INSERT INTO `t_sys_file_info` VALUES (1106, NULL, NULL, NULL, NULL, '16a2e1ddffd31235.jpg', '16a2e1ddffd31235.jpg');
INSERT INTO `t_sys_file_info` VALUES (1107, NULL, NULL, NULL, NULL, '16a2e23221431236.png', '16a2e23221431236.png');
INSERT INTO `t_sys_file_info` VALUES (1108, NULL, NULL, NULL, NULL, '16a2e669c3d31245.png', '16a2e669c3d31245.png');
INSERT INTO `t_sys_file_info` VALUES (1109, NULL, NULL, NULL, NULL, '16a2eff4fea31256.png', '16a2eff4fea31256.png');
INSERT INTO `t_sys_file_info` VALUES (1110, NULL, NULL, NULL, NULL, '16a2f50c8fc31458.jpg', '16a2f50c8fc31458.jpg');
INSERT INTO `t_sys_file_info` VALUES (1111, NULL, NULL, NULL, NULL, '16a2f79c80531521.jpg', '16a2f79c80531521.jpg');
INSERT INTO `t_sys_file_info` VALUES (1112, NULL, NULL, NULL, NULL, '16a2fb8ebda31579.jpg', '16a2fb8ebda31579.jpg');
INSERT INTO `t_sys_file_info` VALUES (1113, NULL, NULL, NULL, NULL, '16a2fc9eee831587.png', '16a2fc9eee831587.png');
INSERT INTO `t_sys_file_info` VALUES (1114, NULL, NULL, NULL, NULL, '16a30b60aeb31707.png', '16a30b60aeb31707.png');
INSERT INTO `t_sys_file_info` VALUES (1115, NULL, NULL, NULL, NULL, '16a3441471e31817.jpg', '16a3441471e31817.jpg');
INSERT INTO `t_sys_file_info` VALUES (1116, NULL, NULL, NULL, NULL, '16a385630f532383.jpg', '16a385630f532383.jpg');
INSERT INTO `t_sys_file_info` VALUES (1117, NULL, NULL, NULL, NULL, '16a39e9560632400.png', '16a39e9560632400.png');
INSERT INTO `t_sys_file_info` VALUES (1118, NULL, NULL, NULL, NULL, '16a3a868a5e32409.png', '16a3a868a5e32409.png');
INSERT INTO `t_sys_file_info` VALUES (1119, NULL, NULL, NULL, NULL, '16a3b2b225132415.jpg', '16a3b2b225132415.jpg');
INSERT INTO `t_sys_file_info` VALUES (1120, NULL, NULL, NULL, NULL, '16a3b44348f32416.jpg', '16a3b44348f32416.jpg');
INSERT INTO `t_sys_file_info` VALUES (1121, NULL, NULL, NULL, NULL, '16a3b463fa532419.jpg', '16a3b463fa532419.jpg');
INSERT INTO `t_sys_file_info` VALUES (1122, NULL, NULL, NULL, NULL, '16a3d8da58332450.jpg', '16a3d8da58332450.jpg');
INSERT INTO `t_sys_file_info` VALUES (1123, NULL, NULL, NULL, NULL, '16a3ecdc05232485.jpg', '16a3ecdc05232485.jpg');
INSERT INTO `t_sys_file_info` VALUES (1124, NULL, NULL, NULL, NULL, '16a3ecf966432486.jpg', '16a3ecf966432486.jpg');
INSERT INTO `t_sys_file_info` VALUES (1125, NULL, NULL, NULL, NULL, '16a3ed0c7d532487.jpg', '16a3ed0c7d532487.jpg');
INSERT INTO `t_sys_file_info` VALUES (1126, NULL, NULL, NULL, NULL, '16a42e3120132563.jpg', '16a42e3120132563.jpg');
INSERT INTO `t_sys_file_info` VALUES (1127, NULL, NULL, NULL, NULL, '16a4332789632586.jpg', '16a4332789632586.jpg');
INSERT INTO `t_sys_file_info` VALUES (1128, NULL, NULL, NULL, NULL, '16a4334096f32587.jpg', '16a4334096f32587.jpg');
INSERT INTO `t_sys_file_info` VALUES (1129, NULL, NULL, NULL, NULL, '16a4375cd3232590.png', '16a4375cd3232590.png');
INSERT INTO `t_sys_file_info` VALUES (1130, NULL, NULL, NULL, NULL, '16a4429bc3232623.png', '16a4429bc3232623.png');
INSERT INTO `t_sys_file_info` VALUES (1131, NULL, NULL, NULL, NULL, '16a442c81fa32624.jpg', '16a442c81fa32624.jpg');
INSERT INTO `t_sys_file_info` VALUES (1132, NULL, NULL, NULL, NULL, '16a4464152632686.jpg', '16a4464152632686.jpg');
INSERT INTO `t_sys_file_info` VALUES (1133, NULL, NULL, NULL, NULL, '16a4464f4d432687.jpg', '16a4464f4d432687.jpg');
INSERT INTO `t_sys_file_info` VALUES (1134, NULL, NULL, NULL, NULL, '16a44b9f3d832771.jpeg', '16a44b9f3d832771.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1135, NULL, NULL, NULL, NULL, '16a44d89a9532822.jpg', '16a44d89a9532822.jpg');
INSERT INTO `t_sys_file_info` VALUES (1136, NULL, NULL, NULL, NULL, '16a4586fd3632993.jpg', '16a4586fd3632993.jpg');
INSERT INTO `t_sys_file_info` VALUES (1137, NULL, NULL, NULL, NULL, '16a459dda9332996.jpg', '16a459dda9332996.jpg');
INSERT INTO `t_sys_file_info` VALUES (1138, NULL, NULL, NULL, NULL, '16a459e765032997.jpg', '16a459e765032997.jpg');
INSERT INTO `t_sys_file_info` VALUES (1139, NULL, NULL, NULL, NULL, '16a45a0760e32998.jpg', '16a45a0760e32998.jpg');
INSERT INTO `t_sys_file_info` VALUES (1140, NULL, NULL, NULL, NULL, '16a45a896cd32999.jpg', '16a45a896cd32999.jpg');
INSERT INTO `t_sys_file_info` VALUES (1141, NULL, NULL, NULL, NULL, '16a45ab220c33000.jpg', '16a45ab220c33000.jpg');
INSERT INTO `t_sys_file_info` VALUES (1142, NULL, NULL, NULL, NULL, '16a45ac6c2033001.jpg', '16a45ac6c2033001.jpg');
INSERT INTO `t_sys_file_info` VALUES (1143, NULL, NULL, NULL, NULL, '16a45ad15e533002.jpg', '16a45ad15e533002.jpg');
INSERT INTO `t_sys_file_info` VALUES (1144, NULL, NULL, NULL, NULL, '16a45b38a9733003.jpg', '16a45b38a9733003.jpg');
INSERT INTO `t_sys_file_info` VALUES (1145, NULL, NULL, NULL, NULL, '16a45b4fd8f33004.jpg', '16a45b4fd8f33004.jpg');
INSERT INTO `t_sys_file_info` VALUES (1146, NULL, NULL, NULL, NULL, '16a45b8e9d933005.jpg', '16a45b8e9d933005.jpg');
INSERT INTO `t_sys_file_info` VALUES (1147, NULL, NULL, NULL, NULL, '16a47ce8fe033080.png', '16a47ce8fe033080.png');
INSERT INTO `t_sys_file_info` VALUES (1148, NULL, NULL, NULL, NULL, '16a483d92ba33162.jpg', '16a483d92ba33162.jpg');
INSERT INTO `t_sys_file_info` VALUES (1149, NULL, NULL, NULL, NULL, '16a483eda3a33168.jpg', '16a483eda3a33168.jpg');
INSERT INTO `t_sys_file_info` VALUES (1150, NULL, NULL, NULL, NULL, '16a48b3d61933223.png', '16a48b3d61933223.png');
INSERT INTO `t_sys_file_info` VALUES (1151, NULL, NULL, NULL, NULL, '16a48c2867933248.png', '16a48c2867933248.png');
INSERT INTO `t_sys_file_info` VALUES (1152, NULL, NULL, NULL, NULL, '16a49313b6a33301.png', '16a49313b6a33301.png');
INSERT INTO `t_sys_file_info` VALUES (1153, NULL, NULL, NULL, NULL, '16a493b093f33306.jpg', '16a493b093f33306.jpg');
INSERT INTO `t_sys_file_info` VALUES (1154, NULL, NULL, NULL, NULL, '16a4941e88d33309.png', '16a4941e88d33309.png');
INSERT INTO `t_sys_file_info` VALUES (1155, NULL, NULL, NULL, NULL, '16a4942612c33310.jpg', '16a4942612c33310.jpg');
INSERT INTO `t_sys_file_info` VALUES (1156, NULL, NULL, NULL, NULL, '16a49466af933311.png', '16a49466af933311.png');
INSERT INTO `t_sys_file_info` VALUES (1157, NULL, NULL, NULL, NULL, '16a4947e48633312.png', '16a4947e48633312.png');
INSERT INTO `t_sys_file_info` VALUES (1158, NULL, NULL, NULL, NULL, '16a494a4a7333313.jpg', '16a494a4a7333313.jpg');
INSERT INTO `t_sys_file_info` VALUES (1159, NULL, NULL, NULL, NULL, '16a497cbc5033369.png', '16a497cbc5033369.png');
INSERT INTO `t_sys_file_info` VALUES (1160, NULL, NULL, NULL, NULL, '16a49fc1b8033431.jpg', '16a49fc1b8033431.jpg');
INSERT INTO `t_sys_file_info` VALUES (1161, NULL, NULL, NULL, NULL, '16a4d12db5e33483.png', '16a4d12db5e33483.png');
INSERT INTO `t_sys_file_info` VALUES (1162, NULL, NULL, NULL, NULL, '16a4d1851d133487.jpg', '16a4d1851d133487.jpg');
INSERT INTO `t_sys_file_info` VALUES (1163, NULL, NULL, NULL, NULL, '16a4d3c69a433510.png', '16a4d3c69a433510.png');
INSERT INTO `t_sys_file_info` VALUES (1164, NULL, NULL, NULL, NULL, '16a4dd8806b33515.jpg', '16a4dd8806b33515.jpg');
INSERT INTO `t_sys_file_info` VALUES (1165, NULL, NULL, NULL, NULL, '16a4dda424633516.jpg', '16a4dda424633516.jpg');
INSERT INTO `t_sys_file_info` VALUES (1166, NULL, NULL, NULL, NULL, '16a4de0d5b933518.jpg', '16a4de0d5b933518.jpg');
INSERT INTO `t_sys_file_info` VALUES (1167, NULL, NULL, NULL, NULL, '16a4ed918a333548.png', '16a4ed918a333548.png');
INSERT INTO `t_sys_file_info` VALUES (1168, NULL, NULL, NULL, NULL, '16a4eda83cb33552.png', '16a4eda83cb33552.png');
INSERT INTO `t_sys_file_info` VALUES (1169, NULL, NULL, NULL, NULL, '16a4fe8024233562.jpg', '16a4fe8024233562.jpg');
INSERT INTO `t_sys_file_info` VALUES (1170, NULL, NULL, NULL, NULL, '16a525f811533581.jpg', '16a525f811533581.jpg');
INSERT INTO `t_sys_file_info` VALUES (1171, NULL, NULL, NULL, NULL, '16a527726a633588.png', '16a527726a633588.png');
INSERT INTO `t_sys_file_info` VALUES (1172, NULL, NULL, NULL, NULL, '16a527a098433590.jpg', '16a527a098433590.jpg');
INSERT INTO `t_sys_file_info` VALUES (1173, NULL, NULL, NULL, NULL, '16a530d697b33600.jpg', '16a530d697b33600.jpg');
INSERT INTO `t_sys_file_info` VALUES (1174, NULL, NULL, NULL, NULL, '16a5324d57533602.png', '16a5324d57533602.png');
INSERT INTO `t_sys_file_info` VALUES (1175, NULL, NULL, NULL, NULL, '16a53fd0da233618.jpg', '16a53fd0da233618.jpg');
INSERT INTO `t_sys_file_info` VALUES (1176, NULL, NULL, NULL, NULL, '16a542b4b9e33642.jpg', '16a542b4b9e33642.jpg');
INSERT INTO `t_sys_file_info` VALUES (1177, NULL, NULL, NULL, NULL, '16a5453678e33646.jpg', '16a5453678e33646.jpg');
INSERT INTO `t_sys_file_info` VALUES (1178, NULL, NULL, NULL, NULL, '16a54546fbe33647.jpg', '16a54546fbe33647.jpg');
INSERT INTO `t_sys_file_info` VALUES (1179, NULL, NULL, NULL, NULL, '16a5512309c33654.jpg', '16a5512309c33654.jpg');
INSERT INTO `t_sys_file_info` VALUES (1180, NULL, NULL, NULL, NULL, '16a5596442c33656.jpg', '16a5596442c33656.jpg');
INSERT INTO `t_sys_file_info` VALUES (1181, NULL, NULL, NULL, NULL, '16a57441ad933658.jpeg', '16a57441ad933658.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1182, NULL, NULL, NULL, NULL, '16a5870f94333704.png', '16a5870f94333704.png');
INSERT INTO `t_sys_file_info` VALUES (1183, NULL, NULL, NULL, NULL, '16a58a86bbc33733.png', '16a58a86bbc33733.png');
INSERT INTO `t_sys_file_info` VALUES (1184, NULL, NULL, NULL, NULL, '16a58ce89fa33739.jpg', '16a58ce89fa33739.jpg');
INSERT INTO `t_sys_file_info` VALUES (1185, NULL, NULL, NULL, NULL, '16a58f1976b33744.jpg', '16a58f1976b33744.jpg');
INSERT INTO `t_sys_file_info` VALUES (1186, NULL, NULL, NULL, NULL, '16a58f99a1633746.jpg', '16a58f99a1633746.jpg');
INSERT INTO `t_sys_file_info` VALUES (1187, NULL, NULL, NULL, NULL, '16a58fb9a9e33748.jpg', '16a58fb9a9e33748.jpg');
INSERT INTO `t_sys_file_info` VALUES (1188, NULL, NULL, NULL, NULL, '16a5a1b730d33765.png', '16a5a1b730d33765.png');
INSERT INTO `t_sys_file_info` VALUES (1189, NULL, NULL, NULL, NULL, '16a5c6b8e4233768.png', '16a5c6b8e4233768.png');
INSERT INTO `t_sys_file_info` VALUES (1190, NULL, NULL, NULL, NULL, '16a5c6e68a733769.png', '16a5c6e68a733769.png');
INSERT INTO `t_sys_file_info` VALUES (1191, NULL, NULL, NULL, NULL, '16a5c70f3ca33770.png', '16a5c70f3ca33770.png');
INSERT INTO `t_sys_file_info` VALUES (1192, NULL, NULL, NULL, NULL, '16a5d82bdd133775.jpg', '16a5d82bdd133775.jpg');
INSERT INTO `t_sys_file_info` VALUES (1193, NULL, NULL, NULL, NULL, '16a5d877b2533776.jpg', '16a5d877b2533776.jpg');
INSERT INTO `t_sys_file_info` VALUES (1194, NULL, NULL, NULL, NULL, '16a5d8a176533777.jpg', '16a5d8a176533777.jpg');
INSERT INTO `t_sys_file_info` VALUES (1195, NULL, NULL, NULL, NULL, '16a5d8c699733778.jpg', '16a5d8c699733778.jpg');
INSERT INTO `t_sys_file_info` VALUES (1196, NULL, NULL, NULL, NULL, '16a5d8e14b833780.jpg', '16a5d8e14b833780.jpg');
INSERT INTO `t_sys_file_info` VALUES (1197, NULL, NULL, NULL, NULL, '16a5dac3fef33781.png', '16a5dac3fef33781.png');
INSERT INTO `t_sys_file_info` VALUES (1198, NULL, NULL, NULL, NULL, '16a5db1263933782.png', '16a5db1263933782.png');
INSERT INTO `t_sys_file_info` VALUES (1199, NULL, NULL, NULL, NULL, '16a5db2500133783.png', '16a5db2500133783.png');
INSERT INTO `t_sys_file_info` VALUES (1200, NULL, NULL, NULL, NULL, '16a5e751c3833789.jpg', '16a5e751c3833789.jpg');
INSERT INTO `t_sys_file_info` VALUES (1201, NULL, NULL, NULL, NULL, '16a6143162933804.jpg', '16a6143162933804.jpg');
INSERT INTO `t_sys_file_info` VALUES (1202, NULL, NULL, NULL, NULL, '16a6147532e33805.jpg', '16a6147532e33805.jpg');
INSERT INTO `t_sys_file_info` VALUES (1203, NULL, NULL, NULL, NULL, '16a6158b97133806.jpg', '16a6158b97133806.jpg');
INSERT INTO `t_sys_file_info` VALUES (1204, NULL, NULL, NULL, NULL, '16a6175e5bc33810.jpg', '16a6175e5bc33810.jpg');
INSERT INTO `t_sys_file_info` VALUES (1205, NULL, NULL, NULL, NULL, '16a6178597633811.jpeg', '16a6178597633811.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1206, NULL, NULL, NULL, NULL, '16a6179c94833812.jpg', '16a6179c94833812.jpg');
INSERT INTO `t_sys_file_info` VALUES (1207, NULL, NULL, NULL, NULL, '16a617af4a833813.jpg', '16a617af4a833813.jpg');
INSERT INTO `t_sys_file_info` VALUES (1208, NULL, NULL, NULL, NULL, '16a617bb4e633814.jpg', '16a617bb4e633814.jpg');
INSERT INTO `t_sys_file_info` VALUES (1209, NULL, NULL, NULL, NULL, '16a617dc02c33816.jpg', '16a617dc02c33816.jpg');
INSERT INTO `t_sys_file_info` VALUES (1210, NULL, NULL, NULL, NULL, '16a6181cd2133817.jpg', '16a6181cd2133817.jpg');
INSERT INTO `t_sys_file_info` VALUES (1211, NULL, NULL, NULL, NULL, '16a61835e3e33818.jpg', '16a61835e3e33818.jpg');
INSERT INTO `t_sys_file_info` VALUES (1212, NULL, NULL, NULL, NULL, '16a6185d12533821.jpg', '16a6185d12533821.jpg');
INSERT INTO `t_sys_file_info` VALUES (1213, NULL, NULL, NULL, NULL, '16a6186d74933822.jpg', '16a6186d74933822.jpg');
INSERT INTO `t_sys_file_info` VALUES (1214, NULL, NULL, NULL, NULL, '16a61883adf33823.jpg', '16a61883adf33823.jpg');
INSERT INTO `t_sys_file_info` VALUES (1215, NULL, NULL, NULL, NULL, '16a618953f133824.jpg', '16a618953f133824.jpg');
INSERT INTO `t_sys_file_info` VALUES (1216, NULL, NULL, NULL, NULL, '16a618a021c33825.jpg', '16a618a021c33825.jpg');
INSERT INTO `t_sys_file_info` VALUES (1217, NULL, NULL, NULL, NULL, '16a618aea4a33826.jpg', '16a618aea4a33826.jpg');
INSERT INTO `t_sys_file_info` VALUES (1218, NULL, NULL, NULL, NULL, '16a618b8cbd33827.jpg', '16a618b8cbd33827.jpg');
INSERT INTO `t_sys_file_info` VALUES (1219, NULL, NULL, NULL, NULL, '16a6190934633830.jpg', '16a6190934633830.jpg');
INSERT INTO `t_sys_file_info` VALUES (1220, NULL, NULL, NULL, NULL, '16a6191985233831.jpg', '16a6191985233831.jpg');
INSERT INTO `t_sys_file_info` VALUES (1221, NULL, NULL, NULL, NULL, '16a6193f44933833.jpg', '16a6193f44933833.jpg');
INSERT INTO `t_sys_file_info` VALUES (1222, NULL, NULL, NULL, NULL, '16a619b940733836.jpg', '16a619b940733836.jpg');
INSERT INTO `t_sys_file_info` VALUES (1223, NULL, NULL, NULL, NULL, '16a61a28fe333837.jpg', '16a61a28fe333837.jpg');
INSERT INTO `t_sys_file_info` VALUES (1224, NULL, NULL, NULL, NULL, '16a61a41ddb33838.png', '16a61a41ddb33838.png');
INSERT INTO `t_sys_file_info` VALUES (1225, NULL, NULL, NULL, NULL, '16a61a4ad1333839.png', '16a61a4ad1333839.png');
INSERT INTO `t_sys_file_info` VALUES (1226, NULL, NULL, NULL, NULL, '16a61a56a3a33840.png', '16a61a56a3a33840.png');
INSERT INTO `t_sys_file_info` VALUES (1227, NULL, NULL, NULL, NULL, '16a61c6ebe733846.jpg', '16a61c6ebe733846.jpg');
INSERT INTO `t_sys_file_info` VALUES (1228, NULL, NULL, NULL, NULL, '16a61cdf99933850.jpg', '16a61cdf99933850.jpg');
INSERT INTO `t_sys_file_info` VALUES (1229, NULL, NULL, NULL, NULL, '16a61d020b733852.jpg', '16a61d020b733852.jpg');
INSERT INTO `t_sys_file_info` VALUES (1230, NULL, NULL, NULL, NULL, '16a61d0c95533853.jpg', '16a61d0c95533853.jpg');
INSERT INTO `t_sys_file_info` VALUES (1231, NULL, NULL, NULL, NULL, '16a61d1cd3f33854.jpg', '16a61d1cd3f33854.jpg');
INSERT INTO `t_sys_file_info` VALUES (1232, NULL, NULL, NULL, NULL, '16a61d39e2c33855.jpg', '16a61d39e2c33855.jpg');
INSERT INTO `t_sys_file_info` VALUES (1233, NULL, NULL, NULL, NULL, '16a61d4e53333856.jpg', '16a61d4e53333856.jpg');
INSERT INTO `t_sys_file_info` VALUES (1234, NULL, NULL, NULL, NULL, '16a61d7a80633858.jpg', '16a61d7a80633858.jpg');
INSERT INTO `t_sys_file_info` VALUES (1235, NULL, NULL, NULL, NULL, '16a6365d60533882.jpg', '16a6365d60533882.jpg');
INSERT INTO `t_sys_file_info` VALUES (1236, NULL, NULL, NULL, NULL, '16a63c8a96533887.png', '16a63c8a96533887.png');
INSERT INTO `t_sys_file_info` VALUES (1237, NULL, NULL, NULL, NULL, '16a63ca8e5f33888.png', '16a63ca8e5f33888.png');
INSERT INTO `t_sys_file_info` VALUES (1238, NULL, NULL, NULL, NULL, '16a63f803de33889.jpg', '16a63f803de33889.jpg');
INSERT INTO `t_sys_file_info` VALUES (1239, NULL, NULL, NULL, NULL, '16a63fc9be333891.jpg', '16a63fc9be333891.jpg');
INSERT INTO `t_sys_file_info` VALUES (1240, NULL, NULL, NULL, NULL, '16a640ef0a333893.jpg', '16a640ef0a333893.jpg');
INSERT INTO `t_sys_file_info` VALUES (1241, NULL, NULL, NULL, NULL, '16a6475e88c33897.jpg', '16a6475e88c33897.jpg');
INSERT INTO `t_sys_file_info` VALUES (1242, NULL, NULL, NULL, NULL, '16a6476344433898.jpg', '16a6476344433898.jpg');
INSERT INTO `t_sys_file_info` VALUES (1243, NULL, NULL, NULL, NULL, '16a64f5a52633901.jpg', '16a64f5a52633901.jpg');
INSERT INTO `t_sys_file_info` VALUES (1244, NULL, NULL, NULL, NULL, '16a6c37b9cd33997.jpg', '16a6c37b9cd33997.jpg');
INSERT INTO `t_sys_file_info` VALUES (1245, NULL, NULL, NULL, NULL, '16a6d1fab2334021.jpeg', '16a6d1fab2334021.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1246, NULL, NULL, NULL, NULL, '16a6d26c90b34028.jpg', '16a6d26c90b34028.jpg');
INSERT INTO `t_sys_file_info` VALUES (1247, NULL, NULL, NULL, NULL, '16a6d42c05334033.png', '16a6d42c05334033.png');
INSERT INTO `t_sys_file_info` VALUES (1248, NULL, NULL, NULL, NULL, '16a6d5b07bf34034.jpg', '16a6d5b07bf34034.jpg');
INSERT INTO `t_sys_file_info` VALUES (1249, NULL, NULL, NULL, NULL, '16a6d5b64ac34035.jpg', '16a6d5b64ac34035.jpg');
INSERT INTO `t_sys_file_info` VALUES (1250, NULL, NULL, NULL, NULL, '16a6dbd744334046.jpg', '16a6dbd744334046.jpg');
INSERT INTO `t_sys_file_info` VALUES (1251, NULL, NULL, NULL, NULL, '16a719ebad634053.png', '16a719ebad634053.png');
INSERT INTO `t_sys_file_info` VALUES (1252, NULL, NULL, NULL, NULL, '16a72093ec034054.jpg', '16a72093ec034054.jpg');
INSERT INTO `t_sys_file_info` VALUES (1253, NULL, NULL, NULL, NULL, '16a721df35c34057.jpg', '16a721df35c34057.jpg');
INSERT INTO `t_sys_file_info` VALUES (1254, NULL, NULL, NULL, NULL, '16a723cfa8e34058.jpg', '16a723cfa8e34058.jpg');
INSERT INTO `t_sys_file_info` VALUES (1255, NULL, NULL, NULL, NULL, '16a76593c3634067.jpeg', '16a76593c3634067.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1256, NULL, NULL, NULL, NULL, '16a765b8c2634069.jpeg', '16a765b8c2634069.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1257, NULL, NULL, NULL, NULL, '16a7751d37434072.jpg', '16a7751d37434072.jpg');
INSERT INTO `t_sys_file_info` VALUES (1258, NULL, NULL, NULL, NULL, '16a7754c3f934076.jpg', '16a7754c3f934076.jpg');
INSERT INTO `t_sys_file_info` VALUES (1259, NULL, NULL, NULL, NULL, '16a776c11d434083.jpg', '16a776c11d434083.jpg');
INSERT INTO `t_sys_file_info` VALUES (1260, NULL, NULL, NULL, NULL, '16a7772a0e034084.jpg', '16a7772a0e034084.jpg');
INSERT INTO `t_sys_file_info` VALUES (1261, NULL, NULL, NULL, NULL, '16a78365c2834101.jpg', '16a78365c2834101.jpg');
INSERT INTO `t_sys_file_info` VALUES (1262, NULL, NULL, NULL, NULL, '16a78ab4c8a34113.jpg', '16a78ab4c8a34113.jpg');
INSERT INTO `t_sys_file_info` VALUES (1263, NULL, NULL, NULL, NULL, '16a79412b4d34125.png', '16a79412b4d34125.png');
INSERT INTO `t_sys_file_info` VALUES (1264, NULL, NULL, NULL, NULL, '16a7b7d949134129.jpg', '16a7b7d949134129.jpg');
INSERT INTO `t_sys_file_info` VALUES (1265, NULL, NULL, NULL, NULL, '16a7b828a9f34130.jpg', '16a7b828a9f34130.jpg');
INSERT INTO `t_sys_file_info` VALUES (1266, NULL, NULL, NULL, NULL, '16a7d09b87634140.jpg', '16a7d09b87634140.jpg');
INSERT INTO `t_sys_file_info` VALUES (1267, NULL, NULL, NULL, NULL, '16a7d0d12f834141.jpg', '16a7d0d12f834141.jpg');
INSERT INTO `t_sys_file_info` VALUES (1268, NULL, NULL, NULL, NULL, '16a7d22febb34146.png', '16a7d22febb34146.png');
INSERT INTO `t_sys_file_info` VALUES (1269, NULL, NULL, NULL, NULL, '16a7d23891334147.png', '16a7d23891334147.png');
INSERT INTO `t_sys_file_info` VALUES (1270, NULL, NULL, NULL, NULL, '16a7d36f97534150.png', '16a7d36f97534150.png');
INSERT INTO `t_sys_file_info` VALUES (1271, NULL, NULL, NULL, NULL, '16a7d9e00ba34171.png', '16a7d9e00ba34171.png');
INSERT INTO `t_sys_file_info` VALUES (1272, NULL, NULL, NULL, NULL, '16a7daa121434175.png', '16a7daa121434175.png');
INSERT INTO `t_sys_file_info` VALUES (1273, NULL, NULL, NULL, NULL, '16a7dbb2f0e34177.jpg', '16a7dbb2f0e34177.jpg');
INSERT INTO `t_sys_file_info` VALUES (1274, NULL, NULL, NULL, NULL, '16a7e1b1fd034183.jpg', '16a7e1b1fd034183.jpg');
INSERT INTO `t_sys_file_info` VALUES (1275, NULL, NULL, NULL, NULL, '16a7e6d598d34186.png', '16a7e6d598d34186.png');
INSERT INTO `t_sys_file_info` VALUES (1276, NULL, NULL, NULL, NULL, '16a804d1cf634190.jpg', '16a804d1cf634190.jpg');
INSERT INTO `t_sys_file_info` VALUES (1277, NULL, NULL, NULL, NULL, '16a804e280a34193.jpg', '16a804e280a34193.jpg');
INSERT INTO `t_sys_file_info` VALUES (1278, NULL, NULL, NULL, NULL, '16a80524ce834197.jpg', '16a80524ce834197.jpg');
INSERT INTO `t_sys_file_info` VALUES (1279, NULL, NULL, NULL, NULL, '16a8057f10c34200.jpg', '16a8057f10c34200.jpg');
INSERT INTO `t_sys_file_info` VALUES (1280, NULL, NULL, NULL, NULL, '16a8060530734203.jpg', '16a8060530734203.jpg');
INSERT INTO `t_sys_file_info` VALUES (1281, NULL, NULL, NULL, NULL, '16a8066382734204.jpg', '16a8066382734204.jpg');
INSERT INTO `t_sys_file_info` VALUES (1282, NULL, NULL, NULL, NULL, '16a807fdd7c34219.jpg', '16a807fdd7c34219.jpg');
INSERT INTO `t_sys_file_info` VALUES (1283, NULL, NULL, NULL, NULL, '16a80877d4134222.jpg', '16a80877d4134222.jpg');
INSERT INTO `t_sys_file_info` VALUES (1284, NULL, NULL, NULL, NULL, '16a8098775e34227.png', '16a8098775e34227.png');
INSERT INTO `t_sys_file_info` VALUES (1285, NULL, NULL, NULL, NULL, '16a80ae821534231.jpg', '16a80ae821534231.jpg');
INSERT INTO `t_sys_file_info` VALUES (1286, NULL, NULL, NULL, NULL, '16a80ba8f6934235.png', '16a80ba8f6934235.png');
INSERT INTO `t_sys_file_info` VALUES (1287, NULL, NULL, NULL, NULL, '16a80e3b9e934239.png', '16a80e3b9e934239.png');
INSERT INTO `t_sys_file_info` VALUES (1288, NULL, NULL, NULL, NULL, '16a80e6bde134248.jpg', '16a80e6bde134248.jpg');
INSERT INTO `t_sys_file_info` VALUES (1289, NULL, NULL, NULL, NULL, '16a81c47c7434274.jpg', '16a81c47c7434274.jpg');
INSERT INTO `t_sys_file_info` VALUES (1290, NULL, NULL, NULL, NULL, '16a81ce128234276.jpg', '16a81ce128234276.jpg');
INSERT INTO `t_sys_file_info` VALUES (1291, NULL, NULL, NULL, NULL, '16a81e82c4e34291.png', '16a81e82c4e34291.png');
INSERT INTO `t_sys_file_info` VALUES (1292, NULL, NULL, NULL, NULL, '16a81ebe45034298.png', '16a81ebe45034298.png');
INSERT INTO `t_sys_file_info` VALUES (1293, NULL, NULL, NULL, NULL, '16a82a9929334484.png', '16a82a9929334484.png');
INSERT INTO `t_sys_file_info` VALUES (1294, NULL, NULL, NULL, NULL, '16a831b9b7e34506.png', '16a831b9b7e34506.png');
INSERT INTO `t_sys_file_info` VALUES (1295, NULL, NULL, NULL, NULL, '16a834784ec34509.jpg', '16a834784ec34509.jpg');
INSERT INTO `t_sys_file_info` VALUES (1296, NULL, NULL, NULL, NULL, '16a85ad04c934542.jpg', '16a85ad04c934542.jpg');
INSERT INTO `t_sys_file_info` VALUES (1297, NULL, NULL, NULL, NULL, '16a86ae9a0534734.jpg', '16a86ae9a0534734.jpg');
INSERT INTO `t_sys_file_info` VALUES (1298, NULL, NULL, NULL, NULL, '16a86b9b54f34772.jpg', '16a86b9b54f34772.jpg');
INSERT INTO `t_sys_file_info` VALUES (1299, NULL, NULL, NULL, NULL, '16a86c3065934816.jpg', '16a86c3065934816.jpg');
INSERT INTO `t_sys_file_info` VALUES (1300, NULL, NULL, NULL, NULL, '16a86e3c8e334940.jpg', '16a86e3c8e334940.jpg');
INSERT INTO `t_sys_file_info` VALUES (1301, NULL, NULL, NULL, NULL, '16a874cf6fd35049.jpg', '16a874cf6fd35049.jpg');
INSERT INTO `t_sys_file_info` VALUES (1302, NULL, NULL, NULL, NULL, '16a8790032535105.png', '16a8790032535105.png');
INSERT INTO `t_sys_file_info` VALUES (1303, NULL, NULL, NULL, NULL, '16a879e258d35111.jpg', '16a879e258d35111.jpg');
INSERT INTO `t_sys_file_info` VALUES (1304, NULL, NULL, NULL, NULL, '16a87b1fb3035140.jpg', '16a87b1fb3035140.jpg');
INSERT INTO `t_sys_file_info` VALUES (1305, NULL, NULL, NULL, NULL, '16a87bcd60735165.jpg', '16a87bcd60735165.jpg');
INSERT INTO `t_sys_file_info` VALUES (1306, NULL, NULL, NULL, NULL, '16a87cf4a6e35199.png', '16a87cf4a6e35199.png');
INSERT INTO `t_sys_file_info` VALUES (1307, NULL, NULL, NULL, NULL, '16a87d01f2a35200.jpg', '16a87d01f2a35200.jpg');
INSERT INTO `t_sys_file_info` VALUES (1308, NULL, NULL, NULL, NULL, '16a87db0ba735217.png', '16a87db0ba735217.png');
INSERT INTO `t_sys_file_info` VALUES (1309, NULL, NULL, NULL, NULL, '16a880cbb8635329.jpg', '16a880cbb8635329.jpg');
INSERT INTO `t_sys_file_info` VALUES (1310, NULL, NULL, NULL, NULL, '16a8a91085235420.jpg', '16a8a91085235420.jpg');
INSERT INTO `t_sys_file_info` VALUES (1311, NULL, NULL, NULL, NULL, '16a8a994e3735449.jpg', '16a8a994e3735449.jpg');
INSERT INTO `t_sys_file_info` VALUES (1312, NULL, NULL, NULL, NULL, '16a8a9ac8cf35451.jpg', '16a8a9ac8cf35451.jpg');
INSERT INTO `t_sys_file_info` VALUES (1313, NULL, NULL, NULL, NULL, '16a8aac0ed735490.jpg', '16a8aac0ed735490.jpg');
INSERT INTO `t_sys_file_info` VALUES (1314, NULL, NULL, NULL, NULL, '16a8abce9eb35507.jpg', '16a8abce9eb35507.jpg');
INSERT INTO `t_sys_file_info` VALUES (1315, NULL, NULL, NULL, NULL, '16a8ac0746b35517.jpg', '16a8ac0746b35517.jpg');
INSERT INTO `t_sys_file_info` VALUES (1316, NULL, NULL, NULL, NULL, '16a8ac6830d35526.jpg', '16a8ac6830d35526.jpg');
INSERT INTO `t_sys_file_info` VALUES (1317, NULL, NULL, NULL, NULL, '16a8ac7199435527.png', '16a8ac7199435527.png');
INSERT INTO `t_sys_file_info` VALUES (1318, NULL, NULL, NULL, NULL, '16a8ac852ee35531.jpg', '16a8ac852ee35531.jpg');
INSERT INTO `t_sys_file_info` VALUES (1319, NULL, NULL, NULL, NULL, '16a8ad1d89935563.jpg', '16a8ad1d89935563.jpg');
INSERT INTO `t_sys_file_info` VALUES (1320, NULL, NULL, NULL, NULL, '16a8ad5e69035582.jpg', '16a8ad5e69035582.jpg');
INSERT INTO `t_sys_file_info` VALUES (1321, NULL, NULL, NULL, NULL, '16a8ae28a4935598.jpg', '16a8ae28a4935598.jpg');
INSERT INTO `t_sys_file_info` VALUES (1322, NULL, NULL, NULL, NULL, '16a8af85f8035612.jpg', '16a8af85f8035612.jpg');
INSERT INTO `t_sys_file_info` VALUES (1323, NULL, NULL, NULL, NULL, '16a8af9486035613.jpg', '16a8af9486035613.jpg');
INSERT INTO `t_sys_file_info` VALUES (1324, NULL, NULL, NULL, NULL, '16a8b0268db35620.jpg', '16a8b0268db35620.jpg');
INSERT INTO `t_sys_file_info` VALUES (1325, NULL, NULL, NULL, NULL, '16a8bc59b0735636.jpg', '16a8bc59b0735636.jpg');
INSERT INTO `t_sys_file_info` VALUES (1326, NULL, NULL, NULL, NULL, '16a8bc6a9d235638.jpg', '16a8bc6a9d235638.jpg');
INSERT INTO `t_sys_file_info` VALUES (1327, NULL, NULL, NULL, NULL, '16a8bc76fa735640.jpg', '16a8bc76fa735640.jpg');
INSERT INTO `t_sys_file_info` VALUES (1328, NULL, NULL, NULL, NULL, '16a8be0ec9735662.png', '16a8be0ec9735662.png');
INSERT INTO `t_sys_file_info` VALUES (1329, NULL, NULL, NULL, NULL, '16a8bf0a06535675.jpg', '16a8bf0a06535675.jpg');
INSERT INTO `t_sys_file_info` VALUES (1330, NULL, NULL, NULL, NULL, '16a8bf65b0f35686.jpg', '16a8bf65b0f35686.jpg');
INSERT INTO `t_sys_file_info` VALUES (1331, NULL, NULL, NULL, NULL, '16a8c007eb935698.jpg', '16a8c007eb935698.jpg');
INSERT INTO `t_sys_file_info` VALUES (1332, NULL, NULL, NULL, NULL, '16a8c091bce35711.jpg', '16a8c091bce35711.jpg');
INSERT INTO `t_sys_file_info` VALUES (1333, NULL, NULL, NULL, NULL, '16a8c1fadb835737.jpg', '16a8c1fadb835737.jpg');
INSERT INTO `t_sys_file_info` VALUES (1334, NULL, NULL, NULL, NULL, '16a8c3954bb35751.jpg', '16a8c3954bb35751.jpg');
INSERT INTO `t_sys_file_info` VALUES (1335, NULL, NULL, NULL, NULL, '16a8c3e0c1c35756.jpg', '16a8c3e0c1c35756.jpg');
INSERT INTO `t_sys_file_info` VALUES (1336, NULL, NULL, NULL, NULL, '16a8c3f687f35761.jpg', '16a8c3f687f35761.jpg');
INSERT INTO `t_sys_file_info` VALUES (1337, NULL, NULL, NULL, NULL, '16a8c49cc2535772.jpg', '16a8c49cc2535772.jpg');
INSERT INTO `t_sys_file_info` VALUES (1338, NULL, NULL, NULL, NULL, '16a8c4e3c3635778.jpg', '16a8c4e3c3635778.jpg');
INSERT INTO `t_sys_file_info` VALUES (1339, NULL, NULL, NULL, NULL, '16a8c559e9935786.jpg', '16a8c559e9935786.jpg');
INSERT INTO `t_sys_file_info` VALUES (1340, NULL, NULL, NULL, NULL, '16a8c57fe6135792.jpg', '16a8c57fe6135792.jpg');
INSERT INTO `t_sys_file_info` VALUES (1341, NULL, NULL, NULL, NULL, '16a8c5a048d35798.png', '16a8c5a048d35798.png');
INSERT INTO `t_sys_file_info` VALUES (1342, NULL, NULL, NULL, NULL, '16a8c5eb4cb35810.jpg', '16a8c5eb4cb35810.jpg');
INSERT INTO `t_sys_file_info` VALUES (1343, NULL, NULL, NULL, NULL, '16a8c67425d35821.jpg', '16a8c67425d35821.jpg');
INSERT INTO `t_sys_file_info` VALUES (1344, NULL, NULL, NULL, NULL, '16a8c69820735824.jpg', '16a8c69820735824.jpg');
INSERT INTO `t_sys_file_info` VALUES (1345, NULL, NULL, NULL, NULL, '16a8c857a6d35834.jpg', '16a8c857a6d35834.jpg');
INSERT INTO `t_sys_file_info` VALUES (1346, NULL, NULL, NULL, NULL, '16a8c92b69735838.jpg', '16a8c92b69735838.jpg');
INSERT INTO `t_sys_file_info` VALUES (1347, NULL, NULL, NULL, NULL, '16a8cb220e835843.jpg', '16a8cb220e835843.jpg');
INSERT INTO `t_sys_file_info` VALUES (1348, NULL, NULL, NULL, NULL, '16a8cb7898635847.jpg', '16a8cb7898635847.jpg');
INSERT INTO `t_sys_file_info` VALUES (1349, NULL, NULL, NULL, NULL, '16a8cbb32ab35851.jpg', '16a8cbb32ab35851.jpg');
INSERT INTO `t_sys_file_info` VALUES (1350, NULL, NULL, NULL, NULL, '16a8cbc365535858.jpg', '16a8cbc365535858.jpg');
INSERT INTO `t_sys_file_info` VALUES (1351, NULL, NULL, NULL, NULL, '16a8cbf122f35864.jpg', '16a8cbf122f35864.jpg');
INSERT INTO `t_sys_file_info` VALUES (1352, NULL, NULL, NULL, NULL, '16a8cbf801735867.jpg', '16a8cbf801735867.jpg');
INSERT INTO `t_sys_file_info` VALUES (1353, NULL, NULL, NULL, NULL, '16a8cc12e5235868.png', '16a8cc12e5235868.png');
INSERT INTO `t_sys_file_info` VALUES (1354, NULL, NULL, NULL, NULL, '16a8ccac9bc35879.jpg', '16a8ccac9bc35879.jpg');
INSERT INTO `t_sys_file_info` VALUES (1355, NULL, NULL, NULL, NULL, '16a8ccfaa4a35890.jpg', '16a8ccfaa4a35890.jpg');
INSERT INTO `t_sys_file_info` VALUES (1356, NULL, NULL, NULL, NULL, '16a8cd13efb35893.jpg', '16a8cd13efb35893.jpg');
INSERT INTO `t_sys_file_info` VALUES (1357, NULL, NULL, NULL, NULL, '16a8ce2788535918.jpg', '16a8ce2788535918.jpg');
INSERT INTO `t_sys_file_info` VALUES (1358, NULL, NULL, NULL, NULL, '16a8ce3a6fc35922.jpg', '16a8ce3a6fc35922.jpg');
INSERT INTO `t_sys_file_info` VALUES (1359, NULL, NULL, NULL, NULL, '16a8cef741735932.jpg', '16a8cef741735932.jpg');
INSERT INTO `t_sys_file_info` VALUES (1360, NULL, NULL, NULL, NULL, '16a8cf0749735933.jpg', '16a8cf0749735933.jpg');
INSERT INTO `t_sys_file_info` VALUES (1361, NULL, NULL, NULL, NULL, '16a8cf8376335938.jpg', '16a8cf8376335938.jpg');
INSERT INTO `t_sys_file_info` VALUES (1362, NULL, NULL, NULL, NULL, '16a8d090f6435959.jpg', '16a8d090f6435959.jpg');
INSERT INTO `t_sys_file_info` VALUES (1363, NULL, NULL, NULL, NULL, '16a8d1b120035981.png', '16a8d1b120035981.png');
INSERT INTO `t_sys_file_info` VALUES (1364, NULL, NULL, NULL, NULL, '16a8d1ee38c35987.jpg', '16a8d1ee38c35987.jpg');
INSERT INTO `t_sys_file_info` VALUES (1365, NULL, NULL, NULL, NULL, '16a8d2e50ab35993.png', '16a8d2e50ab35993.png');
INSERT INTO `t_sys_file_info` VALUES (1366, NULL, NULL, NULL, NULL, '16a8d2e567535994.jpg', '16a8d2e567535994.jpg');
INSERT INTO `t_sys_file_info` VALUES (1367, NULL, NULL, NULL, NULL, '16a8d3c9c1336000.jpg', '16a8d3c9c1336000.jpg');
INSERT INTO `t_sys_file_info` VALUES (1368, NULL, NULL, NULL, NULL, '16a8d3d52f636004.png', '16a8d3d52f636004.png');
INSERT INTO `t_sys_file_info` VALUES (1369, NULL, NULL, NULL, NULL, '16a8f99fb2836012.jpg', '16a8f99fb2836012.jpg');
INSERT INTO `t_sys_file_info` VALUES (1370, NULL, NULL, NULL, NULL, '16a8f9c731f36016.jpg', '16a8f9c731f36016.jpg');
INSERT INTO `t_sys_file_info` VALUES (1371, NULL, NULL, NULL, NULL, '16a8f9e5c0536019.jpg', '16a8f9e5c0536019.jpg');
INSERT INTO `t_sys_file_info` VALUES (1372, NULL, NULL, NULL, NULL, '16a8fa2021336021.jpg', '16a8fa2021336021.jpg');
INSERT INTO `t_sys_file_info` VALUES (1373, NULL, NULL, NULL, NULL, '16a8fa40e5236022.jpg', '16a8fa40e5236022.jpg');
INSERT INTO `t_sys_file_info` VALUES (1374, NULL, NULL, NULL, NULL, '16a8fa5163436026.jpg', '16a8fa5163436026.jpg');
INSERT INTO `t_sys_file_info` VALUES (1375, NULL, NULL, NULL, NULL, '16a8fa720df36028.jpg', '16a8fa720df36028.jpg');
INSERT INTO `t_sys_file_info` VALUES (1376, NULL, NULL, NULL, NULL, '16a8fa9049136032.png', '16a8fa9049136032.png');
INSERT INTO `t_sys_file_info` VALUES (1377, NULL, NULL, NULL, NULL, '16a8fa9cb4536033.jpg', '16a8fa9cb4536033.jpg');
INSERT INTO `t_sys_file_info` VALUES (1378, NULL, NULL, NULL, NULL, '16a8faf3c6236037.jpg', '16a8faf3c6236037.jpg');
INSERT INTO `t_sys_file_info` VALUES (1379, NULL, NULL, NULL, NULL, '16a8fb4c8ba36043.jpg', '16a8fb4c8ba36043.jpg');
INSERT INTO `t_sys_file_info` VALUES (1380, NULL, NULL, NULL, NULL, '16a8fb7cff236057.jpg', '16a8fb7cff236057.jpg');
INSERT INTO `t_sys_file_info` VALUES (1381, NULL, NULL, NULL, NULL, '16a8fb81d8536060.png', '16a8fb81d8536060.png');
INSERT INTO `t_sys_file_info` VALUES (1382, NULL, NULL, NULL, NULL, '16a8fb8c6f236064.jpeg', '16a8fb8c6f236064.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1383, NULL, NULL, NULL, NULL, '16a8fbae6fb36076.png', '16a8fbae6fb36076.png');
INSERT INTO `t_sys_file_info` VALUES (1384, NULL, NULL, NULL, NULL, '16a8fbc014836081.jpg', '16a8fbc014836081.jpg');
INSERT INTO `t_sys_file_info` VALUES (1385, NULL, NULL, NULL, NULL, '16a8fbc777936084.jpg', '16a8fbc777936084.jpg');
INSERT INTO `t_sys_file_info` VALUES (1386, NULL, NULL, NULL, NULL, '16a8fbcd4cd36088.jpg', '16a8fbcd4cd36088.jpg');
INSERT INTO `t_sys_file_info` VALUES (1387, NULL, NULL, NULL, NULL, '16a8fbcff2b36089.jpg', '16a8fbcff2b36089.jpg');
INSERT INTO `t_sys_file_info` VALUES (1388, NULL, NULL, NULL, NULL, '16a8fbeb76436090.jpg', '16a8fbeb76436090.jpg');
INSERT INTO `t_sys_file_info` VALUES (1389, NULL, NULL, NULL, NULL, '16a8fc39b9836101.jpg', '16a8fc39b9836101.jpg');
INSERT INTO `t_sys_file_info` VALUES (1390, NULL, NULL, NULL, NULL, '16a8fc4136836103.png', '16a8fc4136836103.png');
INSERT INTO `t_sys_file_info` VALUES (1391, NULL, NULL, NULL, NULL, '16a8fc74ee636105.png', '16a8fc74ee636105.png');
INSERT INTO `t_sys_file_info` VALUES (1392, NULL, NULL, NULL, NULL, '16a8fc7f25b36109.jpg', '16a8fc7f25b36109.jpg');
INSERT INTO `t_sys_file_info` VALUES (1393, NULL, NULL, NULL, NULL, '16a8fc7f98d36110.jpg', '16a8fc7f98d36110.jpg');
INSERT INTO `t_sys_file_info` VALUES (1394, NULL, NULL, NULL, NULL, '16a8fce8b1d36116.jpg', '16a8fce8b1d36116.jpg');
INSERT INTO `t_sys_file_info` VALUES (1395, NULL, NULL, NULL, NULL, '16a8fcff2b036117.jpg', '16a8fcff2b036117.jpg');
INSERT INTO `t_sys_file_info` VALUES (1396, NULL, NULL, NULL, NULL, '16a8fd0e13f36120.jpg', '16a8fd0e13f36120.jpg');
INSERT INTO `t_sys_file_info` VALUES (1397, NULL, NULL, NULL, NULL, '16a8fd1f5dc36123.jpg', '16a8fd1f5dc36123.jpg');
INSERT INTO `t_sys_file_info` VALUES (1398, NULL, NULL, NULL, NULL, '16a8fd572a336134.png', '16a8fd572a336134.png');
INSERT INTO `t_sys_file_info` VALUES (1399, NULL, NULL, NULL, NULL, '16a8fd5f84a36138.png', '16a8fd5f84a36138.png');
INSERT INTO `t_sys_file_info` VALUES (1400, NULL, NULL, NULL, NULL, '16a8fd6829f36143.jpg', '16a8fd6829f36143.jpg');
INSERT INTO `t_sys_file_info` VALUES (1401, NULL, NULL, NULL, NULL, '16a8fd9c0ca36147.png', '16a8fd9c0ca36147.png');
INSERT INTO `t_sys_file_info` VALUES (1402, NULL, NULL, NULL, NULL, '16a8fdbbaeb36155.png', '16a8fdbbaeb36155.png');
INSERT INTO `t_sys_file_info` VALUES (1403, NULL, NULL, NULL, NULL, '16a8fde18ce36164.jpg', '16a8fde18ce36164.jpg');
INSERT INTO `t_sys_file_info` VALUES (1404, NULL, NULL, NULL, NULL, '16a8fdeea0d36169.png', '16a8fdeea0d36169.png');
INSERT INTO `t_sys_file_info` VALUES (1405, NULL, NULL, NULL, NULL, '16a8fe2a5fa36174.jpg', '16a8fe2a5fa36174.jpg');
INSERT INTO `t_sys_file_info` VALUES (1406, NULL, NULL, NULL, NULL, '16a8fe4f58836178.jpg', '16a8fe4f58836178.jpg');
INSERT INTO `t_sys_file_info` VALUES (1407, NULL, NULL, NULL, NULL, '16a8fe5ddd436185.jpg', '16a8fe5ddd436185.jpg');
INSERT INTO `t_sys_file_info` VALUES (1408, NULL, NULL, NULL, NULL, '16a8fed39f336199.jpg', '16a8fed39f336199.jpg');
INSERT INTO `t_sys_file_info` VALUES (1409, NULL, NULL, NULL, NULL, '16a8ff075ce36208.jpg', '16a8ff075ce36208.jpg');
INSERT INTO `t_sys_file_info` VALUES (1410, NULL, NULL, NULL, NULL, '16a8ff23e0436211.jpg', '16a8ff23e0436211.jpg');
INSERT INTO `t_sys_file_info` VALUES (1411, NULL, NULL, NULL, NULL, '16a8ff2e56436214.jpg', '16a8ff2e56436214.jpg');
INSERT INTO `t_sys_file_info` VALUES (1412, NULL, NULL, NULL, NULL, '16a8ff560d336218.jpg', '16a8ff560d336218.jpg');
INSERT INTO `t_sys_file_info` VALUES (1413, NULL, NULL, NULL, NULL, '16a9007432236228.jpg', '16a9007432236228.jpg');
INSERT INTO `t_sys_file_info` VALUES (1414, NULL, NULL, NULL, NULL, '16a9011c36e36234.png', '16a9011c36e36234.png');
INSERT INTO `t_sys_file_info` VALUES (1415, NULL, NULL, NULL, NULL, '16a9013be6236237.jpg', '16a9013be6236237.jpg');
INSERT INTO `t_sys_file_info` VALUES (1416, NULL, NULL, NULL, NULL, '16a901f6bae36246.png', '16a901f6bae36246.png');
INSERT INTO `t_sys_file_info` VALUES (1417, NULL, NULL, NULL, NULL, '16a9023864a36256.jpg', '16a9023864a36256.jpg');
INSERT INTO `t_sys_file_info` VALUES (1418, NULL, NULL, NULL, NULL, '16a9028e13336267.jpg', '16a9028e13336267.jpg');
INSERT INTO `t_sys_file_info` VALUES (1419, NULL, NULL, NULL, NULL, '16a9029539636270.jpg', '16a9029539636270.jpg');
INSERT INTO `t_sys_file_info` VALUES (1420, NULL, NULL, NULL, NULL, '16a902d8d2536279.jpg', '16a902d8d2536279.jpg');
INSERT INTO `t_sys_file_info` VALUES (1421, NULL, NULL, NULL, NULL, '16a904d1d1a36316.jpg', '16a904d1d1a36316.jpg');
INSERT INTO `t_sys_file_info` VALUES (1422, NULL, NULL, NULL, NULL, '16a905896d936321.jpg', '16a905896d936321.jpg');
INSERT INTO `t_sys_file_info` VALUES (1423, NULL, NULL, NULL, NULL, '16a9060166736322.jpg', '16a9060166736322.jpg');
INSERT INTO `t_sys_file_info` VALUES (1424, NULL, NULL, NULL, NULL, '16a9070d50e36348.jpg', '16a9070d50e36348.jpg');
INSERT INTO `t_sys_file_info` VALUES (1425, NULL, NULL, NULL, NULL, '16a90bd7e2d36360.png', '16a90bd7e2d36360.png');
INSERT INTO `t_sys_file_info` VALUES (1426, NULL, NULL, NULL, NULL, '16a90ccc2ad36362.jpg', '16a90ccc2ad36362.jpg');
INSERT INTO `t_sys_file_info` VALUES (1427, NULL, NULL, NULL, NULL, '16a90dd3ef036366.jpg', '16a90dd3ef036366.jpg');
INSERT INTO `t_sys_file_info` VALUES (1428, NULL, NULL, NULL, NULL, '16a90e0889036376.jpg', '16a90e0889036376.jpg');
INSERT INTO `t_sys_file_info` VALUES (1429, NULL, NULL, NULL, NULL, '16a90e1055536378.jpg', '16a90e1055536378.jpg');
INSERT INTO `t_sys_file_info` VALUES (1430, NULL, NULL, NULL, NULL, '16a90e76ba736393.jpg', '16a90e76ba736393.jpg');
INSERT INTO `t_sys_file_info` VALUES (1431, NULL, NULL, NULL, NULL, '16a90e7ed0a36394.jpg', '16a90e7ed0a36394.jpg');
INSERT INTO `t_sys_file_info` VALUES (1432, NULL, NULL, NULL, NULL, '16a90e8008636395.jpg', '16a90e8008636395.jpg');
INSERT INTO `t_sys_file_info` VALUES (1433, NULL, NULL, NULL, NULL, '16a90e8987036398.jpg', '16a90e8987036398.jpg');
INSERT INTO `t_sys_file_info` VALUES (1434, NULL, NULL, NULL, NULL, '16a90eb5e4f36406.jpg', '16a90eb5e4f36406.jpg');
INSERT INTO `t_sys_file_info` VALUES (1435, NULL, NULL, NULL, NULL, '16a90ec9ade36414.png', '16a90ec9ade36414.png');
INSERT INTO `t_sys_file_info` VALUES (1436, NULL, NULL, NULL, NULL, '16a90edfdd136425.jpg', '16a90edfdd136425.jpg');
INSERT INTO `t_sys_file_info` VALUES (1437, NULL, NULL, NULL, NULL, '16a90f0488d36434.png', '16a90f0488d36434.png');
INSERT INTO `t_sys_file_info` VALUES (1438, NULL, NULL, NULL, NULL, '16a90f1c54f36438.png', '16a90f1c54f36438.png');
INSERT INTO `t_sys_file_info` VALUES (1439, NULL, NULL, NULL, NULL, '16a90f6591c36454.jpg', '16a90f6591c36454.jpg');
INSERT INTO `t_sys_file_info` VALUES (1440, NULL, NULL, NULL, NULL, '16a90f6640536455.jpg', '16a90f6640536455.jpg');
INSERT INTO `t_sys_file_info` VALUES (1441, NULL, NULL, NULL, NULL, '16a90f9550736470.jpg', '16a90f9550736470.jpg');
INSERT INTO `t_sys_file_info` VALUES (1442, NULL, NULL, NULL, NULL, '16a90fd980a36496.png', '16a90fd980a36496.png');
INSERT INTO `t_sys_file_info` VALUES (1443, NULL, NULL, NULL, NULL, '16a90ff37c536515.jpg', '16a90ff37c536515.jpg');
INSERT INTO `t_sys_file_info` VALUES (1444, NULL, NULL, NULL, NULL, '16a90ffbc1536522.jpg', '16a90ffbc1536522.jpg');
INSERT INTO `t_sys_file_info` VALUES (1445, NULL, NULL, NULL, NULL, '16a91028ef736528.png', '16a91028ef736528.png');
INSERT INTO `t_sys_file_info` VALUES (1446, NULL, NULL, NULL, NULL, '16a9103499536532.jpg', '16a9103499536532.jpg');
INSERT INTO `t_sys_file_info` VALUES (1447, NULL, NULL, NULL, NULL, '16a9104b41e36536.png', '16a9104b41e36536.png');
INSERT INTO `t_sys_file_info` VALUES (1448, NULL, NULL, NULL, NULL, '16a91085eee36548.png', '16a91085eee36548.png');
INSERT INTO `t_sys_file_info` VALUES (1449, NULL, NULL, NULL, NULL, '16a9108793736549.jpg', '16a9108793736549.jpg');
INSERT INTO `t_sys_file_info` VALUES (1450, NULL, NULL, NULL, NULL, '16a9109ea2936556.jpg', '16a9109ea2936556.jpg');
INSERT INTO `t_sys_file_info` VALUES (1451, NULL, NULL, NULL, NULL, '16a910cf1b736575.png', '16a910cf1b736575.png');
INSERT INTO `t_sys_file_info` VALUES (1452, NULL, NULL, NULL, NULL, '16a910d387436577.png', '16a910d387436577.png');
INSERT INTO `t_sys_file_info` VALUES (1453, NULL, NULL, NULL, NULL, '16a91135c6836598.jpg', '16a91135c6836598.jpg');
INSERT INTO `t_sys_file_info` VALUES (1454, NULL, NULL, NULL, NULL, '16a911a21ac36617.jpg', '16a911a21ac36617.jpg');
INSERT INTO `t_sys_file_info` VALUES (1455, NULL, NULL, NULL, NULL, '16a9121d2b936653.jpg', '16a9121d2b936653.jpg');
INSERT INTO `t_sys_file_info` VALUES (1456, NULL, NULL, NULL, NULL, '16a9126b80436681.jpg', '16a9126b80436681.jpg');
INSERT INTO `t_sys_file_info` VALUES (1457, NULL, NULL, NULL, NULL, '16a912a073936697.jpg', '16a912a073936697.jpg');
INSERT INTO `t_sys_file_info` VALUES (1458, NULL, NULL, NULL, NULL, '16a912af2dd36699.jpg', '16a912af2dd36699.jpg');
INSERT INTO `t_sys_file_info` VALUES (1459, NULL, NULL, NULL, NULL, '16a912ee76136707.jpg', '16a912ee76136707.jpg');
INSERT INTO `t_sys_file_info` VALUES (1460, NULL, NULL, NULL, NULL, '16a91374ecb36738.jpg', '16a91374ecb36738.jpg');
INSERT INTO `t_sys_file_info` VALUES (1461, NULL, NULL, NULL, NULL, '16a9140b2c836753.jpg', '16a9140b2c836753.jpg');
INSERT INTO `t_sys_file_info` VALUES (1462, NULL, NULL, NULL, NULL, '16a9144321336766.jpg', '16a9144321336766.jpg');
INSERT INTO `t_sys_file_info` VALUES (1463, NULL, NULL, NULL, NULL, '16a91462e6036771.jpg', '16a91462e6036771.jpg');
INSERT INTO `t_sys_file_info` VALUES (1464, NULL, NULL, NULL, NULL, '16a9148a52536790.jpg', '16a9148a52536790.jpg');
INSERT INTO `t_sys_file_info` VALUES (1465, NULL, NULL, NULL, NULL, '16a914d9f3c36795.jpg', '16a914d9f3c36795.jpg');
INSERT INTO `t_sys_file_info` VALUES (1466, NULL, NULL, NULL, NULL, '16a91521b5d36807.jpg', '16a91521b5d36807.jpg');
INSERT INTO `t_sys_file_info` VALUES (1467, NULL, NULL, NULL, NULL, '16a9155ac8836822.jpg', '16a9155ac8836822.jpg');
INSERT INTO `t_sys_file_info` VALUES (1468, NULL, NULL, NULL, NULL, '16a915797b936831.jpg', '16a915797b936831.jpg');
INSERT INTO `t_sys_file_info` VALUES (1469, NULL, NULL, NULL, NULL, '16a9157c2de36832.jpg', '16a9157c2de36832.jpg');
INSERT INTO `t_sys_file_info` VALUES (1470, NULL, NULL, NULL, NULL, '16a915c359436841.jpg', '16a915c359436841.jpg');
INSERT INTO `t_sys_file_info` VALUES (1471, NULL, NULL, NULL, NULL, '16a91617fbf36871.jpg', '16a91617fbf36871.jpg');
INSERT INTO `t_sys_file_info` VALUES (1472, NULL, NULL, NULL, NULL, '16a917309a936935.jpg', '16a917309a936935.jpg');
INSERT INTO `t_sys_file_info` VALUES (1473, NULL, NULL, NULL, NULL, '16a91768bf836956.jpg', '16a91768bf836956.jpg');
INSERT INTO `t_sys_file_info` VALUES (1474, NULL, NULL, NULL, NULL, '16a917ab32836968.jpg', '16a917ab32836968.jpg');
INSERT INTO `t_sys_file_info` VALUES (1475, NULL, NULL, NULL, NULL, '16a917b6b7f36975.jpg', '16a917b6b7f36975.jpg');
INSERT INTO `t_sys_file_info` VALUES (1476, NULL, NULL, NULL, NULL, '16a917bee3436977.jpg', '16a917bee3436977.jpg');
INSERT INTO `t_sys_file_info` VALUES (1477, NULL, NULL, NULL, NULL, '16a917c1d5136978.jpg', '16a917c1d5136978.jpg');
INSERT INTO `t_sys_file_info` VALUES (1478, NULL, NULL, NULL, NULL, '16a9183654236999.jpg', '16a9183654236999.jpg');
INSERT INTO `t_sys_file_info` VALUES (1479, NULL, NULL, NULL, NULL, '16a9183827837000.jpg', '16a9183827837000.jpg');
INSERT INTO `t_sys_file_info` VALUES (1480, NULL, NULL, NULL, NULL, '16a9184792d37003.jpg', '16a9184792d37003.jpg');
INSERT INTO `t_sys_file_info` VALUES (1481, NULL, NULL, NULL, NULL, '16a9185936037005.jpg', '16a9185936037005.jpg');
INSERT INTO `t_sys_file_info` VALUES (1482, NULL, NULL, NULL, NULL, '16a918df04237013.jpg', '16a918df04237013.jpg');
INSERT INTO `t_sys_file_info` VALUES (1483, NULL, NULL, NULL, NULL, '16a91909e8137018.jpg', '16a91909e8137018.jpg');
INSERT INTO `t_sys_file_info` VALUES (1484, NULL, NULL, NULL, NULL, '16a9199118a37037.jpg', '16a9199118a37037.jpg');
INSERT INTO `t_sys_file_info` VALUES (1485, NULL, NULL, NULL, NULL, '16a919d008b37040.jpg', '16a919d008b37040.jpg');
INSERT INTO `t_sys_file_info` VALUES (1486, NULL, NULL, NULL, NULL, '16a91a14d3637043.jpg', '16a91a14d3637043.jpg');
INSERT INTO `t_sys_file_info` VALUES (1487, NULL, NULL, NULL, NULL, '16a91a8ff5137047.jpg', '16a91a8ff5137047.jpg');
INSERT INTO `t_sys_file_info` VALUES (1488, NULL, NULL, NULL, NULL, '16a91aaf4f037052.png', '16a91aaf4f037052.png');
INSERT INTO `t_sys_file_info` VALUES (1489, NULL, NULL, NULL, NULL, '16a91ad937a37056.jpg', '16a91ad937a37056.jpg');
INSERT INTO `t_sys_file_info` VALUES (1490, NULL, NULL, NULL, NULL, '16a91aef70737059.jpg', '16a91aef70737059.jpg');
INSERT INTO `t_sys_file_info` VALUES (1491, NULL, NULL, NULL, NULL, '16a91b6772237067.png', '16a91b6772237067.png');
INSERT INTO `t_sys_file_info` VALUES (1492, NULL, NULL, NULL, NULL, '16a91d61e8537082.png', '16a91d61e8537082.png');
INSERT INTO `t_sys_file_info` VALUES (1493, NULL, NULL, NULL, NULL, '16a91ddb66b37086.png', '16a91ddb66b37086.png');
INSERT INTO `t_sys_file_info` VALUES (1494, NULL, NULL, NULL, NULL, '16a91e33e8037094.png', '16a91e33e8037094.png');
INSERT INTO `t_sys_file_info` VALUES (1495, NULL, NULL, NULL, NULL, '16a91e61a6d37097.jpg', '16a91e61a6d37097.jpg');
INSERT INTO `t_sys_file_info` VALUES (1496, NULL, NULL, NULL, NULL, '16a91ef7da837112.jpeg', '16a91ef7da837112.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1497, NULL, NULL, NULL, NULL, '16a9208bbbf37142.jpg', '16a9208bbbf37142.jpg');
INSERT INTO `t_sys_file_info` VALUES (1498, NULL, NULL, NULL, NULL, '16a9208c47e37143.jpg', '16a9208c47e37143.jpg');
INSERT INTO `t_sys_file_info` VALUES (1499, NULL, NULL, NULL, NULL, '16a9214b48837173.jpg', '16a9214b48837173.jpg');
INSERT INTO `t_sys_file_info` VALUES (1500, NULL, NULL, NULL, NULL, '16a9215a11837180.jpg', '16a9215a11837180.jpg');
INSERT INTO `t_sys_file_info` VALUES (1501, NULL, NULL, NULL, NULL, '16a9216acf737184.jpg', '16a9216acf737184.jpg');
INSERT INTO `t_sys_file_info` VALUES (1502, NULL, NULL, NULL, NULL, '16a921e742e37225.jpeg', '16a921e742e37225.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1503, NULL, NULL, NULL, NULL, '16a922084ad37231.jpg', '16a922084ad37231.jpg');
INSERT INTO `t_sys_file_info` VALUES (1504, NULL, NULL, NULL, NULL, '16a922546aa37243.jpg', '16a922546aa37243.jpg');
INSERT INTO `t_sys_file_info` VALUES (1505, NULL, NULL, NULL, NULL, '16a922edf2937252.jpg', '16a922edf2937252.jpg');
INSERT INTO `t_sys_file_info` VALUES (1506, NULL, NULL, NULL, NULL, '16a922f9ab137254.jpg', '16a922f9ab137254.jpg');
INSERT INTO `t_sys_file_info` VALUES (1507, NULL, NULL, NULL, NULL, '16a924022ae37267.jpg', '16a924022ae37267.jpg');
INSERT INTO `t_sys_file_info` VALUES (1508, NULL, NULL, NULL, NULL, '16a9243838c37272.jpg', '16a9243838c37272.jpg');
INSERT INTO `t_sys_file_info` VALUES (1509, NULL, NULL, NULL, NULL, '16a9245134d37273.jpg', '16a9245134d37273.jpg');
INSERT INTO `t_sys_file_info` VALUES (1510, NULL, NULL, NULL, NULL, '16a9246bb2037274.jpg', '16a9246bb2037274.jpg');
INSERT INTO `t_sys_file_info` VALUES (1511, NULL, NULL, NULL, NULL, '16a9249385f37275.jpg', '16a9249385f37275.jpg');
INSERT INTO `t_sys_file_info` VALUES (1512, NULL, NULL, NULL, NULL, '16a9249cb1b37276.jpg', '16a9249cb1b37276.jpg');
INSERT INTO `t_sys_file_info` VALUES (1513, NULL, NULL, NULL, NULL, '16a924a447d37280.jpg', '16a924a447d37280.jpg');
INSERT INTO `t_sys_file_info` VALUES (1514, NULL, NULL, NULL, NULL, '16a924e83a937289.jpg', '16a924e83a937289.jpg');
INSERT INTO `t_sys_file_info` VALUES (1515, NULL, NULL, NULL, NULL, '16a924efc7c37292.jpg', '16a924efc7c37292.jpg');
INSERT INTO `t_sys_file_info` VALUES (1516, NULL, NULL, NULL, NULL, '16a92518faa37298.jpg', '16a92518faa37298.jpg');
INSERT INTO `t_sys_file_info` VALUES (1517, NULL, NULL, NULL, NULL, '16a92572b5237310.jpg', '16a92572b5237310.jpg');
INSERT INTO `t_sys_file_info` VALUES (1518, NULL, NULL, NULL, NULL, '16a925795f937311.jpg', '16a925795f937311.jpg');
INSERT INTO `t_sys_file_info` VALUES (1519, NULL, NULL, NULL, NULL, '16a92599a2937312.jpg', '16a92599a2937312.jpg');
INSERT INTO `t_sys_file_info` VALUES (1520, NULL, NULL, NULL, NULL, '16a925a09b037315.jpg', '16a925a09b037315.jpg');
INSERT INTO `t_sys_file_info` VALUES (1521, NULL, NULL, NULL, NULL, '16a925b62d537322.jpg', '16a925b62d537322.jpg');
INSERT INTO `t_sys_file_info` VALUES (1522, NULL, NULL, NULL, NULL, '16a925cc2a037323.jpg', '16a925cc2a037323.jpg');
INSERT INTO `t_sys_file_info` VALUES (1523, NULL, NULL, NULL, NULL, '16a925dff7337329.jpg', '16a925dff7337329.jpg');
INSERT INTO `t_sys_file_info` VALUES (1524, NULL, NULL, NULL, NULL, '16a925e566237330.jpg', '16a925e566237330.jpg');
INSERT INTO `t_sys_file_info` VALUES (1525, NULL, NULL, NULL, NULL, '16a925f8de837336.jpg', '16a925f8de837336.jpg');
INSERT INTO `t_sys_file_info` VALUES (1526, NULL, NULL, NULL, NULL, '16a925facf837337.png', '16a925facf837337.png');
INSERT INTO `t_sys_file_info` VALUES (1527, NULL, NULL, NULL, NULL, '16a9261c53d37347.jpg', '16a9261c53d37347.jpg');
INSERT INTO `t_sys_file_info` VALUES (1528, NULL, NULL, NULL, NULL, '16a9261c58537345.jpg', '16a9261c58537345.jpg');
INSERT INTO `t_sys_file_info` VALUES (1529, NULL, NULL, NULL, NULL, '16a9268472937351.jpg', '16a9268472937351.jpg');
INSERT INTO `t_sys_file_info` VALUES (1530, NULL, NULL, NULL, NULL, '16a9273259c37380.jpg', '16a9273259c37380.jpg');
INSERT INTO `t_sys_file_info` VALUES (1531, NULL, NULL, NULL, NULL, '16a927cddd337392.jpg', '16a927cddd337392.jpg');
INSERT INTO `t_sys_file_info` VALUES (1532, NULL, NULL, NULL, NULL, '16a927f229a37398.jpg', '16a927f229a37398.jpg');
INSERT INTO `t_sys_file_info` VALUES (1533, NULL, NULL, NULL, NULL, '16a927f5a5137399.jpg', '16a927f5a5137399.jpg');
INSERT INTO `t_sys_file_info` VALUES (1534, NULL, NULL, NULL, NULL, '16a9282928837405.jpg', '16a9282928837405.jpg');
INSERT INTO `t_sys_file_info` VALUES (1535, NULL, NULL, NULL, NULL, '16a9285a3e237410.jpg', '16a9285a3e237410.jpg');
INSERT INTO `t_sys_file_info` VALUES (1536, NULL, NULL, NULL, NULL, '16a928731bf37411.jpg', '16a928731bf37411.jpg');
INSERT INTO `t_sys_file_info` VALUES (1537, NULL, NULL, NULL, NULL, '16a928c88eb37414.png', '16a928c88eb37414.png');
INSERT INTO `t_sys_file_info` VALUES (1538, NULL, NULL, NULL, NULL, '16a928e44e037415.png', '16a928e44e037415.png');
INSERT INTO `t_sys_file_info` VALUES (1539, NULL, NULL, NULL, NULL, '16a9291446737420.jpg', '16a9291446737420.jpg');
INSERT INTO `t_sys_file_info` VALUES (1540, NULL, NULL, NULL, NULL, '16a92c900f037439.jpg', '16a92c900f037439.jpg');
INSERT INTO `t_sys_file_info` VALUES (1541, NULL, NULL, NULL, NULL, '16a92cf1aa337440.jpg', '16a92cf1aa337440.jpg');
INSERT INTO `t_sys_file_info` VALUES (1542, NULL, NULL, NULL, NULL, '16a92d08eb437441.jpg', '16a92d08eb437441.jpg');
INSERT INTO `t_sys_file_info` VALUES (1543, NULL, NULL, NULL, NULL, '16a9304d01e37442.png', '16a9304d01e37442.png');
INSERT INTO `t_sys_file_info` VALUES (1544, NULL, NULL, NULL, NULL, '16a94b4347137445.jpg', '16a94b4347137445.jpg');
INSERT INTO `t_sys_file_info` VALUES (1545, NULL, NULL, NULL, NULL, '16a94cd9b8837457.jpeg', '16a94cd9b8837457.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1546, NULL, NULL, NULL, NULL, '16a94cffbc137460.jpg', '16a94cffbc137460.jpg');
INSERT INTO `t_sys_file_info` VALUES (1547, NULL, NULL, NULL, NULL, '16a94d1f43a37464.jpg', '16a94d1f43a37464.jpg');
INSERT INTO `t_sys_file_info` VALUES (1548, NULL, NULL, NULL, NULL, '16a94d8731637468.jpg', '16a94d8731637468.jpg');
INSERT INTO `t_sys_file_info` VALUES (1549, NULL, NULL, NULL, NULL, '16a94dd934037477.jpg', '16a94dd934037477.jpg');
INSERT INTO `t_sys_file_info` VALUES (1550, NULL, NULL, NULL, NULL, '16a94dedbee37481.jpg', '16a94dedbee37481.jpg');
INSERT INTO `t_sys_file_info` VALUES (1551, NULL, NULL, NULL, NULL, '16a94df609e37484.png', '16a94df609e37484.png');
INSERT INTO `t_sys_file_info` VALUES (1552, NULL, NULL, NULL, NULL, '16a94dfbfbf37487.png', '16a94dfbfbf37487.png');
INSERT INTO `t_sys_file_info` VALUES (1553, NULL, NULL, NULL, NULL, '16a94e295ef37492.jpeg', '16a94e295ef37492.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1554, NULL, NULL, NULL, NULL, '16a94e30c4c37498.jpg', '16a94e30c4c37498.jpg');
INSERT INTO `t_sys_file_info` VALUES (1555, NULL, NULL, NULL, NULL, '16a94e4e22f37501.png', '16a94e4e22f37501.png');
INSERT INTO `t_sys_file_info` VALUES (1556, NULL, NULL, NULL, NULL, '16a94e51fdb37504.jpg', '16a94e51fdb37504.jpg');
INSERT INTO `t_sys_file_info` VALUES (1557, NULL, NULL, NULL, NULL, '16a94e7267c37505.jpg', '16a94e7267c37505.jpg');
INSERT INTO `t_sys_file_info` VALUES (1558, NULL, NULL, NULL, NULL, '16a94e7e8cc37506.jpg', '16a94e7e8cc37506.jpg');
INSERT INTO `t_sys_file_info` VALUES (1559, NULL, NULL, NULL, NULL, '16a94e9dba837511.jpg', '16a94e9dba837511.jpg');
INSERT INTO `t_sys_file_info` VALUES (1560, NULL, NULL, NULL, NULL, '16a94eab41837515.jpg', '16a94eab41837515.jpg');
INSERT INTO `t_sys_file_info` VALUES (1561, NULL, NULL, NULL, NULL, '16a94eb8e6b37516.png', '16a94eb8e6b37516.png');
INSERT INTO `t_sys_file_info` VALUES (1562, NULL, NULL, NULL, NULL, '16a94f1117037530.jpg', '16a94f1117037530.jpg');
INSERT INTO `t_sys_file_info` VALUES (1563, NULL, NULL, NULL, NULL, '16a94f1bebd37535.jpg', '16a94f1bebd37535.jpg');
INSERT INTO `t_sys_file_info` VALUES (1564, NULL, NULL, NULL, NULL, '16a94f35cf037541.jpg', '16a94f35cf037541.jpg');
INSERT INTO `t_sys_file_info` VALUES (1565, NULL, NULL, NULL, NULL, '16a94f3b64437542.png', '16a94f3b64437542.png');
INSERT INTO `t_sys_file_info` VALUES (1566, NULL, NULL, NULL, NULL, '16a94fb839637562.png', '16a94fb839637562.png');
INSERT INTO `t_sys_file_info` VALUES (1567, NULL, NULL, NULL, NULL, '16a9505270637581.jpg', '16a9505270637581.jpg');
INSERT INTO `t_sys_file_info` VALUES (1568, NULL, NULL, NULL, NULL, '16a95331aea37671.jpg', '16a95331aea37671.jpg');
INSERT INTO `t_sys_file_info` VALUES (1569, NULL, NULL, NULL, NULL, '16a9533b2b337672.png', '16a9533b2b337672.png');
INSERT INTO `t_sys_file_info` VALUES (1570, NULL, NULL, NULL, NULL, '16a953ffb5637691.jpeg', '16a953ffb5637691.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1571, NULL, NULL, NULL, NULL, '16a9540160837692.jpg', '16a9540160837692.jpg');
INSERT INTO `t_sys_file_info` VALUES (1572, NULL, NULL, NULL, NULL, '16a95418e3e37698.jpg', '16a95418e3e37698.jpg');
INSERT INTO `t_sys_file_info` VALUES (1573, NULL, NULL, NULL, NULL, '16a954222ad37700.jpg', '16a954222ad37700.jpg');
INSERT INTO `t_sys_file_info` VALUES (1574, NULL, NULL, NULL, NULL, '16a95449ea437708.jpeg', '16a95449ea437708.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1575, NULL, NULL, NULL, NULL, '16a9545df6037712.jpg', '16a9545df6037712.jpg');
INSERT INTO `t_sys_file_info` VALUES (1576, NULL, NULL, NULL, NULL, '16a9547ff2a37716.jpg', '16a9547ff2a37716.jpg');
INSERT INTO `t_sys_file_info` VALUES (1577, NULL, NULL, NULL, NULL, '16a954ae4e137730.jpg', '16a954ae4e137730.jpg');
INSERT INTO `t_sys_file_info` VALUES (1578, NULL, NULL, NULL, NULL, '16a954fe74737741.jpeg', '16a954fe74737741.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1579, NULL, NULL, NULL, NULL, '16a9551433837746.jpg', '16a9551433837746.jpg');
INSERT INTO `t_sys_file_info` VALUES (1580, NULL, NULL, NULL, NULL, '16a9556dc4b37771.jpeg', '16a9556dc4b37771.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1581, NULL, NULL, NULL, NULL, '16a9556fdd337772.jpg', '16a9556fdd337772.jpg');
INSERT INTO `t_sys_file_info` VALUES (1582, NULL, NULL, NULL, NULL, '16a955a940a37788.jpg', '16a955a940a37788.jpg');
INSERT INTO `t_sys_file_info` VALUES (1583, NULL, NULL, NULL, NULL, '16a955bae4637802.jpeg', '16a955bae4637802.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1584, NULL, NULL, NULL, NULL, '16a955bdc7337810.png', '16a955bdc7337810.png');
INSERT INTO `t_sys_file_info` VALUES (1585, NULL, NULL, NULL, NULL, '16a956133d737831.jpg', '16a956133d737831.jpg');
INSERT INTO `t_sys_file_info` VALUES (1586, NULL, NULL, NULL, NULL, '16a9562ab4c37840.jpeg', '16a9562ab4c37840.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1587, NULL, NULL, NULL, NULL, '16a9562d40137841.jpg', '16a9562d40137841.jpg');
INSERT INTO `t_sys_file_info` VALUES (1588, NULL, NULL, NULL, NULL, '16a9563b54437844.jpeg', '16a9563b54437844.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1589, NULL, NULL, NULL, NULL, '16a9564067a37846.jpg', '16a9564067a37846.jpg');
INSERT INTO `t_sys_file_info` VALUES (1590, NULL, NULL, NULL, NULL, '16a9564e23337850.png', '16a9564e23337850.png');
INSERT INTO `t_sys_file_info` VALUES (1591, NULL, NULL, NULL, NULL, '16a95657c2037854.jpg', '16a95657c2037854.jpg');
INSERT INTO `t_sys_file_info` VALUES (1592, NULL, NULL, NULL, NULL, '16a9565dbbc37856.png', '16a9565dbbc37856.png');
INSERT INTO `t_sys_file_info` VALUES (1593, NULL, NULL, NULL, NULL, '16a95662c5d37858.png', '16a95662c5d37858.png');
INSERT INTO `t_sys_file_info` VALUES (1594, NULL, NULL, NULL, NULL, '16a9566600337859.png', '16a9566600337859.png');
INSERT INTO `t_sys_file_info` VALUES (1595, NULL, NULL, NULL, NULL, '16a95695be937869.png', '16a95695be937869.png');
INSERT INTO `t_sys_file_info` VALUES (1596, NULL, NULL, NULL, NULL, '16a956b61e637874.png', '16a956b61e637874.png');
INSERT INTO `t_sys_file_info` VALUES (1597, NULL, NULL, NULL, NULL, '16a956d29ca37878.jpg', '16a956d29ca37878.jpg');
INSERT INTO `t_sys_file_info` VALUES (1598, NULL, NULL, NULL, NULL, '16a956f734c37883.jpg', '16a956f734c37883.jpg');
INSERT INTO `t_sys_file_info` VALUES (1599, NULL, NULL, NULL, NULL, '16a957215d337885.jpg', '16a957215d337885.jpg');
INSERT INTO `t_sys_file_info` VALUES (1600, NULL, NULL, NULL, NULL, '16a9574514a37891.jpg', '16a9574514a37891.jpg');
INSERT INTO `t_sys_file_info` VALUES (1601, NULL, NULL, NULL, NULL, '16a9577958937901.jpg', '16a9577958937901.jpg');
INSERT INTO `t_sys_file_info` VALUES (1602, NULL, NULL, NULL, NULL, '16a95845ca237930.jpg', '16a95845ca237930.jpg');
INSERT INTO `t_sys_file_info` VALUES (1603, NULL, NULL, NULL, NULL, '16a95879c7837939.jpg', '16a95879c7837939.jpg');
INSERT INTO `t_sys_file_info` VALUES (1604, NULL, NULL, NULL, NULL, '16a95885bff37942.jpg', '16a95885bff37942.jpg');
INSERT INTO `t_sys_file_info` VALUES (1605, NULL, NULL, NULL, NULL, '16a9588cda337944.jpg', '16a9588cda337944.jpg');
INSERT INTO `t_sys_file_info` VALUES (1606, NULL, NULL, NULL, NULL, '16a958a21b737948.jpg', '16a958a21b737948.jpg');
INSERT INTO `t_sys_file_info` VALUES (1607, NULL, NULL, NULL, NULL, '16a958a8f5837950.jpg', '16a958a8f5837950.jpg');
INSERT INTO `t_sys_file_info` VALUES (1608, NULL, NULL, NULL, NULL, '16a95999ab937971.jpg', '16a95999ab937971.jpg');
INSERT INTO `t_sys_file_info` VALUES (1609, NULL, NULL, NULL, NULL, '16a9599f98437972.jpg', '16a9599f98437972.jpg');
INSERT INTO `t_sys_file_info` VALUES (1610, NULL, NULL, NULL, NULL, '16a95a531b937974.jpg', '16a95a531b937974.jpg');
INSERT INTO `t_sys_file_info` VALUES (1611, NULL, NULL, NULL, NULL, '16a95a6094337980.jpg', '16a95a6094337980.jpg');
INSERT INTO `t_sys_file_info` VALUES (1612, NULL, NULL, NULL, NULL, '16a95f1b0db37990.png', '16a95f1b0db37990.png');
INSERT INTO `t_sys_file_info` VALUES (1613, NULL, NULL, NULL, NULL, '16a960e837f38006.jpg', '16a960e837f38006.jpg');
INSERT INTO `t_sys_file_info` VALUES (1614, NULL, NULL, NULL, NULL, '16a9614f83538025.jpg', '16a9614f83538025.jpg');
INSERT INTO `t_sys_file_info` VALUES (1615, NULL, NULL, NULL, NULL, '16a9616c93938029.jpg', '16a9616c93938029.jpg');
INSERT INTO `t_sys_file_info` VALUES (1616, NULL, NULL, NULL, NULL, '16a961eb3c638042.png', '16a961eb3c638042.png');
INSERT INTO `t_sys_file_info` VALUES (1617, NULL, NULL, NULL, NULL, '16a9621361038051.png', '16a9621361038051.png');
INSERT INTO `t_sys_file_info` VALUES (1618, NULL, NULL, NULL, NULL, '16a962212e838058.png', '16a962212e838058.png');
INSERT INTO `t_sys_file_info` VALUES (1619, NULL, NULL, NULL, NULL, '16a9622346b38062.jpg', '16a9622346b38062.jpg');
INSERT INTO `t_sys_file_info` VALUES (1620, NULL, NULL, NULL, NULL, '16a9622b13838063.png', '16a9622b13838063.png');
INSERT INTO `t_sys_file_info` VALUES (1621, NULL, NULL, NULL, NULL, '16a9625435938067.jpg', '16a9625435938067.jpg');
INSERT INTO `t_sys_file_info` VALUES (1622, NULL, NULL, NULL, NULL, '16a9625ba7f38068.png', '16a9625ba7f38068.png');
INSERT INTO `t_sys_file_info` VALUES (1623, NULL, NULL, NULL, NULL, '16a962a6dde38074.jpg', '16a962a6dde38074.jpg');
INSERT INTO `t_sys_file_info` VALUES (1624, NULL, NULL, NULL, NULL, '16a96313efb38079.jpg', '16a96313efb38079.jpg');
INSERT INTO `t_sys_file_info` VALUES (1625, NULL, NULL, NULL, NULL, '16a963d9ec838106.jpg', '16a963d9ec838106.jpg');
INSERT INTO `t_sys_file_info` VALUES (1626, NULL, NULL, NULL, NULL, '16a9640e99f38116.jpg', '16a9640e99f38116.jpg');
INSERT INTO `t_sys_file_info` VALUES (1627, NULL, NULL, NULL, NULL, '16a9646627f38125.jpg', '16a9646627f38125.jpg');
INSERT INTO `t_sys_file_info` VALUES (1628, NULL, NULL, NULL, NULL, '16a9647dec838128.jpg', '16a9647dec838128.jpg');
INSERT INTO `t_sys_file_info` VALUES (1629, NULL, NULL, NULL, NULL, '16a964860d738131.jpg', '16a964860d738131.jpg');
INSERT INTO `t_sys_file_info` VALUES (1630, NULL, NULL, NULL, NULL, '16a964d918838141.jpg', '16a964d918838141.jpg');
INSERT INTO `t_sys_file_info` VALUES (1631, NULL, NULL, NULL, NULL, '16a964e2a3b38143.jpg', '16a964e2a3b38143.jpg');
INSERT INTO `t_sys_file_info` VALUES (1632, NULL, NULL, NULL, NULL, '16a964e58a738145.jpg', '16a964e58a738145.jpg');
INSERT INTO `t_sys_file_info` VALUES (1633, NULL, NULL, NULL, NULL, '16a964f6da038147.jpg', '16a964f6da038147.jpg');
INSERT INTO `t_sys_file_info` VALUES (1634, NULL, NULL, NULL, NULL, '16a9651984238150.jpg', '16a9651984238150.jpg');
INSERT INTO `t_sys_file_info` VALUES (1635, NULL, NULL, NULL, NULL, '16a9657248938163.png', '16a9657248938163.png');
INSERT INTO `t_sys_file_info` VALUES (1636, NULL, NULL, NULL, NULL, '16a965a279a38177.png', '16a965a279a38177.png');
INSERT INTO `t_sys_file_info` VALUES (1637, NULL, NULL, NULL, NULL, '16a965d3d9b38185.jpg', '16a965d3d9b38185.jpg');
INSERT INTO `t_sys_file_info` VALUES (1638, NULL, NULL, NULL, NULL, '16a965e7ae038192.jpg', '16a965e7ae038192.jpg');
INSERT INTO `t_sys_file_info` VALUES (1639, NULL, NULL, NULL, NULL, '16a9700c71138231.jpg', '16a9700c71138231.jpg');
INSERT INTO `t_sys_file_info` VALUES (1640, NULL, NULL, NULL, NULL, '16a9700f30738233.jpg', '16a9700f30738233.jpg');
INSERT INTO `t_sys_file_info` VALUES (1641, NULL, NULL, NULL, NULL, '16a970174b438235.jpg', '16a970174b438235.jpg');
INSERT INTO `t_sys_file_info` VALUES (1642, NULL, NULL, NULL, NULL, '16a9708d5f938239.jpg', '16a9708d5f938239.jpg');
INSERT INTO `t_sys_file_info` VALUES (1643, NULL, NULL, NULL, NULL, '16a970a9d4838244.jpg', '16a970a9d4838244.jpg');
INSERT INTO `t_sys_file_info` VALUES (1644, NULL, NULL, NULL, NULL, '16a97119ca338253.jpg', '16a97119ca338253.jpg');
INSERT INTO `t_sys_file_info` VALUES (1645, NULL, NULL, NULL, NULL, '16a9715e97238256.jpg', '16a9715e97238256.jpg');
INSERT INTO `t_sys_file_info` VALUES (1646, NULL, NULL, NULL, NULL, '16a971ac60738274.png', '16a971ac60738274.png');
INSERT INTO `t_sys_file_info` VALUES (1647, NULL, NULL, NULL, NULL, '16a971c29d038275.jpg', '16a971c29d038275.jpg');
INSERT INTO `t_sys_file_info` VALUES (1648, NULL, NULL, NULL, NULL, '16a971f381938284.jpg', '16a971f381938284.jpg');
INSERT INTO `t_sys_file_info` VALUES (1649, NULL, NULL, NULL, NULL, '16a97232ea138295.png', '16a97232ea138295.png');
INSERT INTO `t_sys_file_info` VALUES (1650, NULL, NULL, NULL, NULL, '16a97236aff38296.jpg', '16a97236aff38296.jpg');
INSERT INTO `t_sys_file_info` VALUES (1651, NULL, NULL, NULL, NULL, '16a97242c7738298.jpg', '16a97242c7738298.jpg');
INSERT INTO `t_sys_file_info` VALUES (1652, NULL, NULL, NULL, NULL, '16a972512b838301.jpg', '16a972512b838301.jpg');
INSERT INTO `t_sys_file_info` VALUES (1653, NULL, NULL, NULL, NULL, '16a9727933338305.jpg', '16a9727933338305.jpg');
INSERT INTO `t_sys_file_info` VALUES (1654, NULL, NULL, NULL, NULL, '16a972f1b3238327.jpg', '16a972f1b3238327.jpg');
INSERT INTO `t_sys_file_info` VALUES (1655, NULL, NULL, NULL, NULL, '16a97302f2738328.jpg', '16a97302f2738328.jpg');
INSERT INTO `t_sys_file_info` VALUES (1656, NULL, NULL, NULL, NULL, '16a97313fc838331.jpg', '16a97313fc838331.jpg');
INSERT INTO `t_sys_file_info` VALUES (1657, NULL, NULL, NULL, NULL, '16a97316ab038332.jpg', '16a97316ab038332.jpg');
INSERT INTO `t_sys_file_info` VALUES (1658, NULL, NULL, NULL, NULL, '16a9734551b38336.jpg', '16a9734551b38336.jpg');
INSERT INTO `t_sys_file_info` VALUES (1659, NULL, NULL, NULL, NULL, '16a97345d5a38337.jpg', '16a97345d5a38337.jpg');
INSERT INTO `t_sys_file_info` VALUES (1660, NULL, NULL, NULL, NULL, '16a9736ccc838340.png', '16a9736ccc838340.png');
INSERT INTO `t_sys_file_info` VALUES (1661, NULL, NULL, NULL, NULL, '16a97392ccd38344.jpg', '16a97392ccd38344.jpg');
INSERT INTO `t_sys_file_info` VALUES (1662, NULL, NULL, NULL, NULL, '16a974d7e0238372.jpg', '16a974d7e0238372.jpg');
INSERT INTO `t_sys_file_info` VALUES (1663, NULL, NULL, NULL, NULL, '16a9757f4eb38382.jpg', '16a9757f4eb38382.jpg');
INSERT INTO `t_sys_file_info` VALUES (1664, NULL, NULL, NULL, NULL, '16a975bb5e738387.jpg', '16a975bb5e738387.jpg');
INSERT INTO `t_sys_file_info` VALUES (1665, NULL, NULL, NULL, NULL, '16a975fb2f438405.jpg', '16a975fb2f438405.jpg');
INSERT INTO `t_sys_file_info` VALUES (1666, NULL, NULL, NULL, NULL, '16a9761ce3938412.png', '16a9761ce3938412.png');
INSERT INTO `t_sys_file_info` VALUES (1667, NULL, NULL, NULL, NULL, '16a976a0f9938438.jpg', '16a976a0f9938438.jpg');
INSERT INTO `t_sys_file_info` VALUES (1668, NULL, NULL, NULL, NULL, '16a976a6e5938440.jpg', '16a976a6e5938440.jpg');
INSERT INTO `t_sys_file_info` VALUES (1669, NULL, NULL, NULL, NULL, '16a976d1ec538446.jpg', '16a976d1ec538446.jpg');
INSERT INTO `t_sys_file_info` VALUES (1670, NULL, NULL, NULL, NULL, '16a9770a8fa38458.jpg', '16a9770a8fa38458.jpg');
INSERT INTO `t_sys_file_info` VALUES (1671, NULL, NULL, NULL, NULL, '16a977be72238495.png', '16a977be72238495.png');
INSERT INTO `t_sys_file_info` VALUES (1672, NULL, NULL, NULL, NULL, '16a977d7cd038497.jpg', '16a977d7cd038497.jpg');
INSERT INTO `t_sys_file_info` VALUES (1673, NULL, NULL, NULL, NULL, '16a9782fe4a38508.jpg', '16a9782fe4a38508.jpg');
INSERT INTO `t_sys_file_info` VALUES (1674, NULL, NULL, NULL, NULL, '16a9785417638511.jpg', '16a9785417638511.jpg');
INSERT INTO `t_sys_file_info` VALUES (1675, NULL, NULL, NULL, NULL, '16a9786b4f338512.jpg', '16a9786b4f338512.jpg');
INSERT INTO `t_sys_file_info` VALUES (1676, NULL, NULL, NULL, NULL, '16a978f56bd38515.jpg', '16a978f56bd38515.jpg');
INSERT INTO `t_sys_file_info` VALUES (1677, NULL, NULL, NULL, NULL, '16a99d0990d38532.jpg', '16a99d0990d38532.jpg');
INSERT INTO `t_sys_file_info` VALUES (1678, NULL, NULL, NULL, NULL, '16a99ee55cd38534.png', '16a99ee55cd38534.png');
INSERT INTO `t_sys_file_info` VALUES (1679, NULL, NULL, NULL, NULL, '16a99f917b438543.jpg', '16a99f917b438543.jpg');
INSERT INTO `t_sys_file_info` VALUES (1680, NULL, NULL, NULL, NULL, '16a99fc61b438547.jpg', '16a99fc61b438547.jpg');
INSERT INTO `t_sys_file_info` VALUES (1681, NULL, NULL, NULL, NULL, '16a99ffe04d38551.jpg', '16a99ffe04d38551.jpg');
INSERT INTO `t_sys_file_info` VALUES (1682, NULL, NULL, NULL, NULL, '16a9a01c44f38552.jpg', '16a9a01c44f38552.jpg');
INSERT INTO `t_sys_file_info` VALUES (1683, NULL, NULL, NULL, NULL, '16a9a05969438560.png', '16a9a05969438560.png');
INSERT INTO `t_sys_file_info` VALUES (1684, NULL, NULL, NULL, NULL, '16a9a066a1238563.jpg', '16a9a066a1238563.jpg');
INSERT INTO `t_sys_file_info` VALUES (1685, NULL, NULL, NULL, NULL, '16a9a0ed44238575.jpg', '16a9a0ed44238575.jpg');
INSERT INTO `t_sys_file_info` VALUES (1686, NULL, NULL, NULL, NULL, '16a9a10bcc938582.jpg', '16a9a10bcc938582.jpg');
INSERT INTO `t_sys_file_info` VALUES (1687, NULL, NULL, NULL, NULL, '16a9a17f7a738596.jpg', '16a9a17f7a738596.jpg');
INSERT INTO `t_sys_file_info` VALUES (1688, NULL, NULL, NULL, NULL, '16a9a19850f38601.jpg', '16a9a19850f38601.jpg');
INSERT INTO `t_sys_file_info` VALUES (1689, NULL, NULL, NULL, NULL, '16a9a1b74d038609.jpg', '16a9a1b74d038609.jpg');
INSERT INTO `t_sys_file_info` VALUES (1690, NULL, NULL, NULL, NULL, '16a9a1d209c38615.jpg', '16a9a1d209c38615.jpg');
INSERT INTO `t_sys_file_info` VALUES (1691, NULL, NULL, NULL, NULL, '16a9a40148038659.jpg', '16a9a40148038659.jpg');
INSERT INTO `t_sys_file_info` VALUES (1692, NULL, NULL, NULL, NULL, '16a9a46391a38674.jpg', '16a9a46391a38674.jpg');
INSERT INTO `t_sys_file_info` VALUES (1693, NULL, NULL, NULL, NULL, '16a9a46615e38678.jpg', '16a9a46615e38678.jpg');
INSERT INTO `t_sys_file_info` VALUES (1694, NULL, NULL, NULL, NULL, '16a9a49586e38692.jpg', '16a9a49586e38692.jpg');
INSERT INTO `t_sys_file_info` VALUES (1695, NULL, NULL, NULL, NULL, '16a9a4c382038703.jpg', '16a9a4c382038703.jpg');
INSERT INTO `t_sys_file_info` VALUES (1696, NULL, NULL, NULL, NULL, '16a9a4ddef638706.png', '16a9a4ddef638706.png');
INSERT INTO `t_sys_file_info` VALUES (1697, NULL, NULL, NULL, NULL, '16a9a4f28d138708.jpg', '16a9a4f28d138708.jpg');
INSERT INTO `t_sys_file_info` VALUES (1698, NULL, NULL, NULL, NULL, '16a9a50273938710.jpg', '16a9a50273938710.jpg');
INSERT INTO `t_sys_file_info` VALUES (1699, NULL, NULL, NULL, NULL, '16a9a565f8038723.jpg', '16a9a565f8038723.jpg');
INSERT INTO `t_sys_file_info` VALUES (1700, NULL, NULL, NULL, NULL, '16a9a59932938730.jpg', '16a9a59932938730.jpg');
INSERT INTO `t_sys_file_info` VALUES (1701, NULL, NULL, NULL, NULL, '16a9a638f1d38755.jpg', '16a9a638f1d38755.jpg');
INSERT INTO `t_sys_file_info` VALUES (1702, NULL, NULL, NULL, NULL, '16a9a64296638757.jpg', '16a9a64296638757.jpg');
INSERT INTO `t_sys_file_info` VALUES (1703, NULL, NULL, NULL, NULL, '16a9a6a6b3f38768.jpg', '16a9a6a6b3f38768.jpg');
INSERT INTO `t_sys_file_info` VALUES (1704, NULL, NULL, NULL, NULL, '16a9a6b65ef38769.jpg', '16a9a6b65ef38769.jpg');
INSERT INTO `t_sys_file_info` VALUES (1705, NULL, NULL, NULL, NULL, '16a9a6e17ff38773.png', '16a9a6e17ff38773.png');
INSERT INTO `t_sys_file_info` VALUES (1706, NULL, NULL, NULL, NULL, '16a9a74359a38785.jpeg', '16a9a74359a38785.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1707, NULL, NULL, NULL, NULL, '16a9a75d43338786.jpeg', '16a9a75d43338786.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1708, NULL, NULL, NULL, NULL, '16a9a776d9338790.jpeg', '16a9a776d9338790.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1709, NULL, NULL, NULL, NULL, '16a9a7a81f938797.jpg', '16a9a7a81f938797.jpg');
INSERT INTO `t_sys_file_info` VALUES (1710, NULL, NULL, NULL, NULL, '16a9a7b2a9538800.jpeg', '16a9a7b2a9538800.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1711, NULL, NULL, NULL, NULL, '16a9a80586e38810.jpg', '16a9a80586e38810.jpg');
INSERT INTO `t_sys_file_info` VALUES (1712, NULL, NULL, NULL, NULL, '16a9a86324238824.jpg', '16a9a86324238824.jpg');
INSERT INTO `t_sys_file_info` VALUES (1713, NULL, NULL, NULL, NULL, '16a9a87345438825.jpg', '16a9a87345438825.jpg');
INSERT INTO `t_sys_file_info` VALUES (1714, NULL, NULL, NULL, NULL, '16a9a9197d738840.jpeg', '16a9a9197d738840.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1715, NULL, NULL, NULL, NULL, '16a9a972ee038848.jpg', '16a9a972ee038848.jpg');
INSERT INTO `t_sys_file_info` VALUES (1716, NULL, NULL, NULL, NULL, '16a9a976eb038849.jpg', '16a9a976eb038849.jpg');
INSERT INTO `t_sys_file_info` VALUES (1717, NULL, NULL, NULL, NULL, '16a9aa25b4738855.jpg', '16a9aa25b4738855.jpg');
INSERT INTO `t_sys_file_info` VALUES (1718, NULL, NULL, NULL, NULL, '16a9aaf29e038862.jpg', '16a9aaf29e038862.jpg');
INSERT INTO `t_sys_file_info` VALUES (1719, NULL, NULL, NULL, NULL, '16a9af9667d38892.jpg', '16a9af9667d38892.jpg');
INSERT INTO `t_sys_file_info` VALUES (1720, NULL, NULL, NULL, NULL, '16a9afb469c38893.jpg', '16a9afb469c38893.jpg');
INSERT INTO `t_sys_file_info` VALUES (1721, NULL, NULL, NULL, NULL, '16a9b31b12838914.jpg', '16a9b31b12838914.jpg');
INSERT INTO `t_sys_file_info` VALUES (1722, NULL, NULL, NULL, NULL, '16a9b350b5638915.jpg', '16a9b350b5638915.jpg');
INSERT INTO `t_sys_file_info` VALUES (1723, NULL, NULL, NULL, NULL, '16a9b37068b38918.jpg', '16a9b37068b38918.jpg');
INSERT INTO `t_sys_file_info` VALUES (1724, NULL, NULL, NULL, NULL, '16a9b39952838923.jpg', '16a9b39952838923.jpg');
INSERT INTO `t_sys_file_info` VALUES (1725, NULL, NULL, NULL, NULL, '16a9b474b3638935.jpg', '16a9b474b3638935.jpg');
INSERT INTO `t_sys_file_info` VALUES (1726, NULL, NULL, NULL, NULL, '16a9b5d4f1c38967.jpg', '16a9b5d4f1c38967.jpg');
INSERT INTO `t_sys_file_info` VALUES (1727, NULL, NULL, NULL, NULL, '16a9b5d6f9a38968.jpg', '16a9b5d6f9a38968.jpg');
INSERT INTO `t_sys_file_info` VALUES (1728, NULL, NULL, NULL, NULL, '16a9b5f0d7e38974.jpg', '16a9b5f0d7e38974.jpg');
INSERT INTO `t_sys_file_info` VALUES (1729, NULL, NULL, NULL, NULL, '16a9b6054cb38978.jpg', '16a9b6054cb38978.jpg');
INSERT INTO `t_sys_file_info` VALUES (1730, NULL, NULL, NULL, NULL, '16a9b6230fb38980.jpg', '16a9b6230fb38980.jpg');
INSERT INTO `t_sys_file_info` VALUES (1731, NULL, NULL, NULL, NULL, '16a9b71107638991.jpg', '16a9b71107638991.jpg');
INSERT INTO `t_sys_file_info` VALUES (1732, NULL, NULL, NULL, NULL, '16a9b7a456639002.jpg', '16a9b7a456639002.jpg');
INSERT INTO `t_sys_file_info` VALUES (1733, NULL, NULL, NULL, NULL, '16a9b7d2f1939006.jpg', '16a9b7d2f1939006.jpg');
INSERT INTO `t_sys_file_info` VALUES (1734, NULL, NULL, NULL, NULL, '16a9b7fa3dd39011.jpg', '16a9b7fa3dd39011.jpg');
INSERT INTO `t_sys_file_info` VALUES (1735, NULL, NULL, NULL, NULL, '16a9b8788b739015.jpg', '16a9b8788b739015.jpg');
INSERT INTO `t_sys_file_info` VALUES (1736, NULL, NULL, NULL, NULL, '16a9b8b1ad039017.jpg', '16a9b8b1ad039017.jpg');
INSERT INTO `t_sys_file_info` VALUES (1737, NULL, NULL, NULL, NULL, '16a9b8e7abb39026.jpg', '16a9b8e7abb39026.jpg');
INSERT INTO `t_sys_file_info` VALUES (1738, NULL, NULL, NULL, NULL, '16a9b99f3a939038.jpg', '16a9b99f3a939038.jpg');
INSERT INTO `t_sys_file_info` VALUES (1739, NULL, NULL, NULL, NULL, '16a9baaf93d39043.jpg', '16a9baaf93d39043.jpg');
INSERT INTO `t_sys_file_info` VALUES (1740, NULL, NULL, NULL, NULL, '16a9bb9059f39048.jpg', '16a9bb9059f39048.jpg');
INSERT INTO `t_sys_file_info` VALUES (1741, NULL, NULL, NULL, NULL, '16a9bbd7b9239049.jpg', '16a9bbd7b9239049.jpg');
INSERT INTO `t_sys_file_info` VALUES (1742, NULL, NULL, NULL, NULL, '16a9bc6161039051.jpeg', '16a9bc6161039051.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1743, NULL, NULL, NULL, NULL, '16a9bc9eed939052.jpg', '16a9bc9eed939052.jpg');
INSERT INTO `t_sys_file_info` VALUES (1744, NULL, NULL, NULL, NULL, '16a9c3991b339068.jpg', '16a9c3991b339068.jpg');
INSERT INTO `t_sys_file_info` VALUES (1745, NULL, NULL, NULL, NULL, '16a9c3c538239069.jpg', '16a9c3c538239069.jpg');
INSERT INTO `t_sys_file_info` VALUES (1746, NULL, NULL, NULL, NULL, '16a9c42c7a039070.jpg', '16a9c42c7a039070.jpg');
INSERT INTO `t_sys_file_info` VALUES (1747, NULL, NULL, NULL, NULL, '16a9c48972c39072.jpg', '16a9c48972c39072.jpg');
INSERT INTO `t_sys_file_info` VALUES (1748, NULL, NULL, NULL, NULL, '16a9c4c2f0c39073.jpg', '16a9c4c2f0c39073.jpg');
INSERT INTO `t_sys_file_info` VALUES (1749, NULL, NULL, NULL, NULL, '16a9c626d3239074.jpg', '16a9c626d3239074.jpg');
INSERT INTO `t_sys_file_info` VALUES (1750, NULL, NULL, NULL, NULL, '16a9c650a4339077.jpg', '16a9c650a4339077.jpg');
INSERT INTO `t_sys_file_info` VALUES (1751, NULL, NULL, NULL, NULL, '16a9c72856a39084.jpg', '16a9c72856a39084.jpg');
INSERT INTO `t_sys_file_info` VALUES (1752, NULL, NULL, NULL, NULL, '16a9f5ec28839125.jpg', '16a9f5ec28839125.jpg');
INSERT INTO `t_sys_file_info` VALUES (1753, NULL, NULL, NULL, NULL, '16a9f6089cf39128.jpg', '16a9f6089cf39128.jpg');
INSERT INTO `t_sys_file_info` VALUES (1754, NULL, NULL, NULL, NULL, '16a9f66231139131.jpg', '16a9f66231139131.jpg');
INSERT INTO `t_sys_file_info` VALUES (1755, NULL, NULL, NULL, NULL, '16a9f67c57639136.jpg', '16a9f67c57639136.jpg');
INSERT INTO `t_sys_file_info` VALUES (1756, NULL, NULL, NULL, NULL, '16a9f69719539141.jpg', '16a9f69719539141.jpg');
INSERT INTO `t_sys_file_info` VALUES (1757, NULL, NULL, NULL, NULL, '16a9f6bfbd039144.jpg', '16a9f6bfbd039144.jpg');
INSERT INTO `t_sys_file_info` VALUES (1758, NULL, NULL, NULL, NULL, '16a9f75b96839155.jpg', '16a9f75b96839155.jpg');
INSERT INTO `t_sys_file_info` VALUES (1759, NULL, NULL, NULL, NULL, '16a9f76cfbd39162.jpg', '16a9f76cfbd39162.jpg');
INSERT INTO `t_sys_file_info` VALUES (1760, NULL, NULL, NULL, NULL, '16a9f7e019a39175.jpg', '16a9f7e019a39175.jpg');
INSERT INTO `t_sys_file_info` VALUES (1761, NULL, NULL, NULL, NULL, '16a9f7f1f9539180.jpg', '16a9f7f1f9539180.jpg');
INSERT INTO `t_sys_file_info` VALUES (1762, NULL, NULL, NULL, NULL, '16a9f977fde39189.jpg', '16a9f977fde39189.jpg');
INSERT INTO `t_sys_file_info` VALUES (1763, NULL, NULL, NULL, NULL, '16a9f9794de39190.jpg', '16a9f9794de39190.jpg');
INSERT INTO `t_sys_file_info` VALUES (1764, NULL, NULL, NULL, NULL, '16a9f97bb6939191.jpg', '16a9f97bb6939191.jpg');
INSERT INTO `t_sys_file_info` VALUES (1765, NULL, NULL, NULL, NULL, '16a9f9a213a39192.jpg', '16a9f9a213a39192.jpg');
INSERT INTO `t_sys_file_info` VALUES (1766, NULL, NULL, NULL, NULL, '16a9f9a323539193.jpg', '16a9f9a323539193.jpg');
INSERT INTO `t_sys_file_info` VALUES (1767, NULL, NULL, NULL, NULL, '16a9fad296e39211.png', '16a9fad296e39211.png');
INSERT INTO `t_sys_file_info` VALUES (1768, NULL, NULL, NULL, NULL, '16a9fb3aaf339216.png', '16a9fb3aaf339216.png');
INSERT INTO `t_sys_file_info` VALUES (1769, NULL, NULL, NULL, NULL, '16a9fc8632a39241.jpg', '16a9fc8632a39241.jpg');
INSERT INTO `t_sys_file_info` VALUES (1770, NULL, NULL, NULL, NULL, '16a9fca24e539247.jpeg', '16a9fca24e539247.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1771, NULL, NULL, NULL, NULL, '16a9fcb024f39248.jpg', '16a9fcb024f39248.jpg');
INSERT INTO `t_sys_file_info` VALUES (1772, NULL, NULL, NULL, NULL, '16a9fd0412c39257.jpg', '16a9fd0412c39257.jpg');
INSERT INTO `t_sys_file_info` VALUES (1773, NULL, NULL, NULL, NULL, '16a9fd58d8b39268.jpg', '16a9fd58d8b39268.jpg');
INSERT INTO `t_sys_file_info` VALUES (1774, NULL, NULL, NULL, NULL, '16a9fd93b4539277.jpg', '16a9fd93b4539277.jpg');
INSERT INTO `t_sys_file_info` VALUES (1775, NULL, NULL, NULL, NULL, '16a9fdb8cb039280.jpg', '16a9fdb8cb039280.jpg');
INSERT INTO `t_sys_file_info` VALUES (1776, NULL, NULL, NULL, NULL, '16a9fddb3da39282.jpg', '16a9fddb3da39282.jpg');
INSERT INTO `t_sys_file_info` VALUES (1777, NULL, NULL, NULL, NULL, '16a9fde030c39283.png', '16a9fde030c39283.png');
INSERT INTO `t_sys_file_info` VALUES (1778, NULL, NULL, NULL, NULL, '16a9fe35bdf39288.png', '16a9fe35bdf39288.png');
INSERT INTO `t_sys_file_info` VALUES (1779, NULL, NULL, NULL, NULL, '16aa0122f8939289.png', '16aa0122f8939289.png');
INSERT INTO `t_sys_file_info` VALUES (1780, NULL, NULL, NULL, NULL, '16aa0141c9f39290.png', '16aa0141c9f39290.png');
INSERT INTO `t_sys_file_info` VALUES (1781, NULL, NULL, NULL, NULL, '16aa01b82b639294.png', '16aa01b82b639294.png');
INSERT INTO `t_sys_file_info` VALUES (1782, NULL, NULL, NULL, NULL, '16aa03c2dd339297.jpg', '16aa03c2dd339297.jpg');
INSERT INTO `t_sys_file_info` VALUES (1783, NULL, NULL, NULL, NULL, '16aa03ceb7e39298.jpg', '16aa03ceb7e39298.jpg');
INSERT INTO `t_sys_file_info` VALUES (1784, NULL, NULL, NULL, NULL, '16aa05136f139301.jpg', '16aa05136f139301.jpg');
INSERT INTO `t_sys_file_info` VALUES (1785, NULL, NULL, NULL, NULL, '16aa053add339305.jpg', '16aa053add339305.jpg');
INSERT INTO `t_sys_file_info` VALUES (1786, NULL, NULL, NULL, NULL, '16aa077a94d39313.png', '16aa077a94d39313.png');
INSERT INTO `t_sys_file_info` VALUES (1787, NULL, NULL, NULL, NULL, '16aa081943339315.jpg', '16aa081943339315.jpg');
INSERT INTO `t_sys_file_info` VALUES (1788, NULL, NULL, NULL, NULL, '16aa083089439316.jpg', '16aa083089439316.jpg');
INSERT INTO `t_sys_file_info` VALUES (1789, NULL, NULL, NULL, NULL, '16aa0a1aa6839320.jpg', '16aa0a1aa6839320.jpg');
INSERT INTO `t_sys_file_info` VALUES (1790, NULL, NULL, NULL, NULL, '16aa0b4551a39325.jpg', '16aa0b4551a39325.jpg');
INSERT INTO `t_sys_file_info` VALUES (1791, NULL, NULL, NULL, NULL, '16aa0b8717a39327.jpg', '16aa0b8717a39327.jpg');
INSERT INTO `t_sys_file_info` VALUES (1792, NULL, NULL, NULL, NULL, '16aa0d59bb039329.png', '16aa0d59bb039329.png');
INSERT INTO `t_sys_file_info` VALUES (1793, NULL, NULL, NULL, NULL, '16aa0e249ba39336.png', '16aa0e249ba39336.png');
INSERT INTO `t_sys_file_info` VALUES (1794, NULL, NULL, NULL, NULL, '16aa0efac7d39340.png', '16aa0efac7d39340.png');
INSERT INTO `t_sys_file_info` VALUES (1795, NULL, NULL, NULL, NULL, '16aa0f014a239341.jpg', '16aa0f014a239341.jpg');
INSERT INTO `t_sys_file_info` VALUES (1796, NULL, NULL, NULL, NULL, '16aa10ab9d139349.jpg', '16aa10ab9d139349.jpg');
INSERT INTO `t_sys_file_info` VALUES (1797, NULL, NULL, NULL, NULL, '16aa48fc18a39372.jpeg', '16aa48fc18a39372.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1798, NULL, NULL, NULL, NULL, '16aa4a4afa339375.jpg', '16aa4a4afa339375.jpg');
INSERT INTO `t_sys_file_info` VALUES (1799, NULL, NULL, NULL, NULL, '16aa6041ed239388.jpg', '16aa6041ed239388.jpg');
INSERT INTO `t_sys_file_info` VALUES (1800, NULL, NULL, NULL, NULL, '16aa62fc33c39392.jpg', '16aa62fc33c39392.jpg');
INSERT INTO `t_sys_file_info` VALUES (1801, NULL, NULL, NULL, NULL, '16aa633129339393.jpg', '16aa633129339393.jpg');
INSERT INTO `t_sys_file_info` VALUES (1802, NULL, NULL, NULL, NULL, '16aa63e09ae39396.jpg', '16aa63e09ae39396.jpg');
INSERT INTO `t_sys_file_info` VALUES (1803, NULL, NULL, NULL, NULL, '16aa63f1faa39397.jpg', '16aa63f1faa39397.jpg');
INSERT INTO `t_sys_file_info` VALUES (1804, NULL, NULL, NULL, NULL, '16aa642318339398.jpg', '16aa642318339398.jpg');
INSERT INTO `t_sys_file_info` VALUES (1805, NULL, NULL, NULL, NULL, '16aa6447d7f39399.jpg', '16aa6447d7f39399.jpg');
INSERT INTO `t_sys_file_info` VALUES (1806, NULL, NULL, NULL, NULL, '16aa75c900839404.jpg', '16aa75c900839404.jpg');
INSERT INTO `t_sys_file_info` VALUES (1807, NULL, NULL, NULL, NULL, '16aa7b144ed39407.jpg', '16aa7b144ed39407.jpg');
INSERT INTO `t_sys_file_info` VALUES (1808, NULL, NULL, NULL, NULL, '16aa7b25d8539408.jpg', '16aa7b25d8539408.jpg');
INSERT INTO `t_sys_file_info` VALUES (1809, NULL, NULL, NULL, NULL, '16aa7b3125239409.jpeg', '16aa7b3125239409.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1810, NULL, NULL, NULL, NULL, '16aa7b4092639410.jpg', '16aa7b4092639410.jpg');
INSERT INTO `t_sys_file_info` VALUES (1811, NULL, NULL, NULL, NULL, '16aa7b4aded39411.jpg', '16aa7b4aded39411.jpg');
INSERT INTO `t_sys_file_info` VALUES (1812, NULL, NULL, NULL, NULL, '16aa7b57fdb39412.jpg', '16aa7b57fdb39412.jpg');
INSERT INTO `t_sys_file_info` VALUES (1813, NULL, NULL, NULL, NULL, '16aa7b69c2039413.jpg', '16aa7b69c2039413.jpg');
INSERT INTO `t_sys_file_info` VALUES (1814, NULL, NULL, NULL, NULL, '16aa7b7417b39414.jpg', '16aa7b7417b39414.jpg');
INSERT INTO `t_sys_file_info` VALUES (1815, NULL, NULL, NULL, NULL, '16aa7bcec1b39415.jpg', '16aa7bcec1b39415.jpg');
INSERT INTO `t_sys_file_info` VALUES (1816, NULL, NULL, NULL, NULL, '16aa7bd7dc139416.jpg', '16aa7bd7dc139416.jpg');
INSERT INTO `t_sys_file_info` VALUES (1817, NULL, NULL, NULL, NULL, '16aa7bfd3e839417.jpg', '16aa7bfd3e839417.jpg');
INSERT INTO `t_sys_file_info` VALUES (1818, NULL, NULL, NULL, NULL, '16aa7c089ee39418.jpg', '16aa7c089ee39418.jpg');
INSERT INTO `t_sys_file_info` VALUES (1819, NULL, NULL, NULL, NULL, '16aa7c116ca39419.jpg', '16aa7c116ca39419.jpg');
INSERT INTO `t_sys_file_info` VALUES (1820, NULL, NULL, NULL, NULL, '16aa7c2798e39420.jpg', '16aa7c2798e39420.jpg');
INSERT INTO `t_sys_file_info` VALUES (1821, NULL, NULL, NULL, NULL, '16aa7c313a739421.jpg', '16aa7c313a739421.jpg');
INSERT INTO `t_sys_file_info` VALUES (1822, NULL, NULL, NULL, NULL, '16aa7c4a5d339422.jpg', '16aa7c4a5d339422.jpg');
INSERT INTO `t_sys_file_info` VALUES (1823, NULL, NULL, NULL, NULL, '16aa7c53bda39423.jpg', '16aa7c53bda39423.jpg');
INSERT INTO `t_sys_file_info` VALUES (1824, NULL, NULL, NULL, NULL, '16aa7c65b4339424.jpg', '16aa7c65b4339424.jpg');
INSERT INTO `t_sys_file_info` VALUES (1825, NULL, NULL, NULL, NULL, '16aa7c7e54039425.jpg', '16aa7c7e54039425.jpg');
INSERT INTO `t_sys_file_info` VALUES (1826, NULL, NULL, NULL, NULL, '16aa7c8652839426.jpg', '16aa7c8652839426.jpg');
INSERT INTO `t_sys_file_info` VALUES (1827, NULL, NULL, NULL, NULL, '16aa7c94d7839427.jpg', '16aa7c94d7839427.jpg');
INSERT INTO `t_sys_file_info` VALUES (1828, NULL, NULL, NULL, NULL, '16aa7ca8de639428.jpg', '16aa7ca8de639428.jpg');
INSERT INTO `t_sys_file_info` VALUES (1829, NULL, NULL, NULL, NULL, '16aa7cb489739429.jpg', '16aa7cb489739429.jpg');
INSERT INTO `t_sys_file_info` VALUES (1830, NULL, NULL, NULL, NULL, '16aa7cc3bbc39430.jpg', '16aa7cc3bbc39430.jpg');
INSERT INTO `t_sys_file_info` VALUES (1831, NULL, NULL, NULL, NULL, '16aa7cdb95039431.jpg', '16aa7cdb95039431.jpg');
INSERT INTO `t_sys_file_info` VALUES (1832, NULL, NULL, NULL, NULL, '16aa7ceaa7439432.jpeg', '16aa7ceaa7439432.jpeg');
INSERT INTO `t_sys_file_info` VALUES (1833, NULL, NULL, NULL, NULL, '16aa7cf25e339433.jpg', '16aa7cf25e339433.jpg');
INSERT INTO `t_sys_file_info` VALUES (1834, NULL, NULL, NULL, NULL, '16aa7d0638d39434.jpg', '16aa7d0638d39434.jpg');
INSERT INTO `t_sys_file_info` VALUES (1835, NULL, NULL, NULL, NULL, '16aa7d27d6639435.jpg', '16aa7d27d6639435.jpg');
INSERT INTO `t_sys_file_info` VALUES (1836, NULL, NULL, NULL, NULL, '16aa7d364c039436.jpg', '16aa7d364c039436.jpg');
INSERT INTO `t_sys_file_info` VALUES (1837, NULL, NULL, NULL, NULL, '16aa7d41f1039437.jpg', '16aa7d41f1039437.jpg');
INSERT INTO `t_sys_file_info` VALUES (1838, NULL, NULL, NULL, NULL, '16aa7d4e48239438.jpg', '16aa7d4e48239438.jpg');
INSERT INTO `t_sys_file_info` VALUES (1839, NULL, NULL, NULL, NULL, '16aa7d5683c39439.jpg', '16aa7d5683c39439.jpg');
INSERT INTO `t_sys_file_info` VALUES (1840, NULL, NULL, NULL, NULL, '16aa7d602c839440.jpg', '16aa7d602c839440.jpg');
INSERT INTO `t_sys_file_info` VALUES (1841, NULL, NULL, NULL, NULL, '16aa7d68d1039441.jpg', '16aa7d68d1039441.jpg');
INSERT INTO `t_sys_file_info` VALUES (1842, NULL, NULL, NULL, NULL, '16aa7e260d639443.jpg', '16aa7e260d639443.jpg');
INSERT INTO `t_sys_file_info` VALUES (1843, NULL, NULL, NULL, NULL, '16aa97b9e7839445.jpg', '16aa97b9e7839445.jpg');
INSERT INTO `t_sys_file_info` VALUES (1844, NULL, NULL, NULL, NULL, '16aa97ef2ed39446.jpg', '16aa97ef2ed39446.jpg');
INSERT INTO `t_sys_file_info` VALUES (1845, NULL, NULL, NULL, NULL, '16aa9837aa439447.jpg', '16aa9837aa439447.jpg');
INSERT INTO `t_sys_file_info` VALUES (1846, NULL, NULL, NULL, NULL, '16aa9b037ef39448.jpg', '16aa9b037ef39448.jpg');
INSERT INTO `t_sys_file_info` VALUES (1847, NULL, NULL, NULL, NULL, '16aa9b56e8439449.jpg', '16aa9b56e8439449.jpg');
INSERT INTO `t_sys_file_info` VALUES (1848, NULL, NULL, NULL, NULL, '16aac179b2739543.jpg', '16aac179b2739543.jpg');
INSERT INTO `t_sys_file_info` VALUES (1849, NULL, NULL, NULL, NULL, '16aac9f3c6339552.jpg', '16aac9f3c6339552.jpg');
INSERT INTO `t_sys_file_info` VALUES (1850, NULL, NULL, NULL, NULL, '16aacca818739554.png', '16aacca818739554.png');
INSERT INTO `t_sys_file_info` VALUES (1851, NULL, NULL, NULL, NULL, '16aaec0e32439559.jpg', '16aaec0e32439559.jpg');
INSERT INTO `t_sys_file_info` VALUES (1852, NULL, NULL, NULL, NULL, '16aaedc63a039561.jpg', '16aaedc63a039561.jpg');
INSERT INTO `t_sys_file_info` VALUES (1853, NULL, NULL, NULL, NULL, '16aaede7abd39564.png', '16aaede7abd39564.png');
INSERT INTO `t_sys_file_info` VALUES (1854, NULL, NULL, NULL, NULL, '16aaedfe7df39565.jpg', '16aaedfe7df39565.jpg');
INSERT INTO `t_sys_file_info` VALUES (1855, NULL, NULL, NULL, NULL, '16aafebf0bc39598.jpg', '16aafebf0bc39598.jpg');
INSERT INTO `t_sys_file_info` VALUES (1856, NULL, NULL, NULL, NULL, '16ab048926539647.jpg', '16ab048926539647.jpg');
INSERT INTO `t_sys_file_info` VALUES (1857, NULL, NULL, NULL, NULL, '16ab06c3dc339661.png', '16ab06c3dc339661.png');
INSERT INTO `t_sys_file_info` VALUES (1858, NULL, NULL, NULL, NULL, '16ab08876fb39682.jpg', '16ab08876fb39682.jpg');
INSERT INTO `t_sys_file_info` VALUES (1859, NULL, NULL, NULL, NULL, '16ab0b070b539688.jpg', '16ab0b070b539688.jpg');
INSERT INTO `t_sys_file_info` VALUES (1860, NULL, NULL, NULL, NULL, '16ab3d692bd39702.jpg', '16ab3d692bd39702.jpg');
INSERT INTO `t_sys_file_info` VALUES (1861, NULL, NULL, NULL, NULL, '16ab45884b939742.jpg', '16ab45884b939742.jpg');
INSERT INTO `t_sys_file_info` VALUES (1862, NULL, NULL, NULL, NULL, '16ab513cda439776.jpg', '16ab513cda439776.jpg');
INSERT INTO `t_sys_file_info` VALUES (1863, NULL, NULL, NULL, NULL, '16ab5163c0f39778.jpg', '16ab5163c0f39778.jpg');
INSERT INTO `t_sys_file_info` VALUES (1864, NULL, NULL, NULL, NULL, '16ab59e880a39830.jpg', '16ab59e880a39830.jpg');
INSERT INTO `t_sys_file_info` VALUES (1865, NULL, NULL, NULL, NULL, '16ab5bb00ae39834.jpg', '16ab5bb00ae39834.jpg');
INSERT INTO `t_sys_file_info` VALUES (1866, NULL, NULL, NULL, NULL, '17d03880-4269-4e7d-aafc-08a256c1aad2.jpg', '17d03880-4269-4e7d-aafc-08a256c1aad2.jpg');
INSERT INTO `t_sys_file_info` VALUES (1867, NULL, NULL, NULL, NULL, '259073d3-07b6-4708-a877-a224cb9a4b64.jpg', '259073d3-07b6-4708-a877-a224cb9a4b64.jpg');
INSERT INTO `t_sys_file_info` VALUES (1868, NULL, NULL, NULL, NULL, '27c8c711-dec4-45de-ba13-cad3c62299bf.jpg', '27c8c711-dec4-45de-ba13-cad3c62299bf.jpg');
INSERT INTO `t_sys_file_info` VALUES (1869, NULL, NULL, NULL, NULL, '289356fc-b750-4895-b512-4deabdf97082.jpg', '289356fc-b750-4895-b512-4deabdf97082.jpg');
INSERT INTO `t_sys_file_info` VALUES (1870, NULL, NULL, NULL, NULL, '29b98535-f8fd-4116-9276-b305b0193149.jpg', '29b98535-f8fd-4116-9276-b305b0193149.jpg');
INSERT INTO `t_sys_file_info` VALUES (1871, NULL, NULL, NULL, NULL, '2a1494f3-2562-4bf6-8cb3-dd08fc612e6d.jpg', '2a1494f3-2562-4bf6-8cb3-dd08fc612e6d.jpg');
INSERT INTO `t_sys_file_info` VALUES (1872, NULL, NULL, NULL, NULL, '2fa1f32b-91f5-4900-8031-cac65b173357.jpg', '2fa1f32b-91f5-4900-8031-cac65b173357.jpg');
INSERT INTO `t_sys_file_info` VALUES (1873, NULL, NULL, NULL, NULL, '326b2b62-c432-42a4-9db7-477af1263087.jpg', '326b2b62-c432-42a4-9db7-477af1263087.jpg');
INSERT INTO `t_sys_file_info` VALUES (1874, NULL, NULL, NULL, NULL, '357aa581-2047-4574-a0e2-0128c3f72b9e.jpg', '357aa581-2047-4574-a0e2-0128c3f72b9e.jpg');
INSERT INTO `t_sys_file_info` VALUES (1875, NULL, NULL, NULL, NULL, '357ade1c-e9c4-43e3-a792-d458988953b7.jpg', '357ade1c-e9c4-43e3-a792-d458988953b7.jpg');
INSERT INTO `t_sys_file_info` VALUES (1876, NULL, NULL, NULL, NULL, '39c4e2a5-96de-47c8-bef4-eefb93f213b7.jpg', '39c4e2a5-96de-47c8-bef4-eefb93f213b7.jpg');
INSERT INTO `t_sys_file_info` VALUES (1877, NULL, NULL, NULL, NULL, '3da3e2dc-caff-40d9-a6f3-e676832acf3e.jpg', '3da3e2dc-caff-40d9-a6f3-e676832acf3e.jpg');
INSERT INTO `t_sys_file_info` VALUES (1878, NULL, NULL, NULL, NULL, '3e45c7cd-fc52-492b-9c0b-4b8235e2e9cf.jpg', '3e45c7cd-fc52-492b-9c0b-4b8235e2e9cf.jpg');
INSERT INTO `t_sys_file_info` VALUES (1879, NULL, NULL, NULL, NULL, '3e58d7f0-a856-4d65-97ad-340dd1c3dda3.jpg', '3e58d7f0-a856-4d65-97ad-340dd1c3dda3.jpg');
INSERT INTO `t_sys_file_info` VALUES (1880, NULL, NULL, NULL, NULL, '3ec157ee-d647-4cb7-b522-1907fdcf6062.jpg', '3ec157ee-d647-4cb7-b522-1907fdcf6062.jpg');
INSERT INTO `t_sys_file_info` VALUES (1881, NULL, NULL, NULL, NULL, '5f27d771-e87b-429e-8929-b1f606809496.jpg', '5f27d771-e87b-429e-8929-b1f606809496.jpg');
INSERT INTO `t_sys_file_info` VALUES (1882, NULL, NULL, NULL, NULL, '62a2507d-b850-4cb8-8744-e5d5c52bd80d.jpg', '62a2507d-b850-4cb8-8744-e5d5c52bd80d.jpg');
INSERT INTO `t_sys_file_info` VALUES (1883, NULL, NULL, NULL, NULL, '6b5768d2-3dfe-40a3-8c15-5133a0ce18cd.jpg', '6b5768d2-3dfe-40a3-8c15-5133a0ce18cd.jpg');
INSERT INTO `t_sys_file_info` VALUES (1884, NULL, NULL, NULL, NULL, '6bcd22dd-8706-43e1-a9aa-bde54e761b24.jpg', '6bcd22dd-8706-43e1-a9aa-bde54e761b24.jpg');
INSERT INTO `t_sys_file_info` VALUES (1885, NULL, NULL, NULL, NULL, '6c932fa4-211a-4303-b2a9-fc1c8e3837ed.jpg', '6c932fa4-211a-4303-b2a9-fc1c8e3837ed.jpg');
INSERT INTO `t_sys_file_info` VALUES (1886, NULL, NULL, NULL, NULL, '78ce5849-84c8-4916-8dea-e0fb75008c6d.jpg', '78ce5849-84c8-4916-8dea-e0fb75008c6d.jpg');
INSERT INTO `t_sys_file_info` VALUES (1887, NULL, NULL, NULL, NULL, '80ef6bfb-c0c3-4a18-a615-c91821de30bb.jpg', '80ef6bfb-c0c3-4a18-a615-c91821de30bb.jpg');
INSERT INTO `t_sys_file_info` VALUES (1888, NULL, NULL, NULL, NULL, '98ef2be6-1f21-4700-a315-4ab307f3e7f0.jpg', '98ef2be6-1f21-4700-a315-4ab307f3e7f0.jpg');
INSERT INTO `t_sys_file_info` VALUES (1889, NULL, NULL, NULL, NULL, 'a356d962-0b53-4f49-b3bf-909e5da95cd3.jpg', 'a356d962-0b53-4f49-b3bf-909e5da95cd3.jpg');
INSERT INTO `t_sys_file_info` VALUES (1890, NULL, NULL, NULL, NULL, 'a463913c-d88e-4dcf-b0f6-b12e721df2f4.jpg', 'a463913c-d88e-4dcf-b0f6-b12e721df2f4.jpg');
INSERT INTO `t_sys_file_info` VALUES (1891, NULL, NULL, NULL, NULL, 'ae4c122d-d824-4890-963a-5a9f98e082e9.jpg', 'ae4c122d-d824-4890-963a-5a9f98e082e9.jpg');
INSERT INTO `t_sys_file_info` VALUES (1892, NULL, NULL, NULL, NULL, 'avatar.jpg', 'avatar.jpg');
INSERT INTO `t_sys_file_info` VALUES (1893, NULL, NULL, NULL, NULL, 'b4094d28-bd8f-4005-b660-30b7993c6eb9.jpg', 'b4094d28-bd8f-4005-b660-30b7993c6eb9.jpg');
INSERT INTO `t_sys_file_info` VALUES (1894, NULL, NULL, NULL, NULL, 'e0bbecd3-a929-4c8d-9f7f-7a904e314dff.jpg', 'e0bbecd3-a929-4c8d-9f7f-7a904e314dff.jpg');
INSERT INTO `t_sys_file_info` VALUES (1895, NULL, NULL, NULL, NULL, 'e3873a74-5083-4166-b594-2369b677363b.jpg', 'e3873a74-5083-4166-b594-2369b677363b.jpg');
INSERT INTO `t_sys_file_info` VALUES (1896, NULL, NULL, NULL, NULL, 'e447c4b9-cef5-4a8f-a689-c7aef557c91a.jpg', 'e447c4b9-cef5-4a8f-a689-c7aef557c91a.jpg');
INSERT INTO `t_sys_file_info` VALUES (1897, NULL, NULL, NULL, NULL, 'ec84d8a4-10ed-42ce-8f1a-313ff70eaf4f.jpg', 'ec84d8a4-10ed-42ce-8f1a-313ff70eaf4f.jpg');
INSERT INTO `t_sys_file_info` VALUES (1898, NULL, NULL, NULL, NULL, 'f3dea320-c3c1-4478-9e5a-71234ca707b7.jpg', 'f3dea320-c3c1-4478-9e5a-71234ca707b7.jpg');
INSERT INTO `t_sys_file_info` VALUES (1899, NULL, NULL, NULL, NULL, 'f769b125-aee6-4bbb-9203-5b8d3faeaee0.jpg', 'f769b125-aee6-4bbb-9203-5b8d3faeaee0.jpg');
INSERT INTO `t_sys_file_info` VALUES (1900, 1, '2023-04-26 11:15:47', 1, '2023-04-26 11:15:47', 'Snipaste.jpg', 'acef5f87-ca9d-46aa-bb4d-b35f743e581b.jpg');

-- ----------------------------
-- Table structure for t_sys_login_log
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_login_log`;
CREATE TABLE `t_sys_login_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `ip` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `logname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `message` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `succeed` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `userid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 73 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '登录日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_login_log
-- ----------------------------
INSERT INTO `t_sys_login_log` VALUES (71, '2019-05-10 13:17:43', '127.0.0.1', '登录日志', NULL, '成功', 1);
INSERT INTO `t_sys_login_log` VALUES (72, '2019-05-12 13:36:56', '127.0.0.1', '登录日志', NULL, '成功', 1);

-- ----------------------------
-- Table structure for t_sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_menu`;
CREATE TABLE `t_sys_menu`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '编号',
  `icon` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '图标',
  `ismenu` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '是否是菜单1:菜单,0:按钮',
  `isopen` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否默认打开1:是,0:否',
  `levels` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '级别',
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '名称',
  `num` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '顺序',
  `pcode` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '父菜单编号',
  `pcodes` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '递归父级菜单编号',
  `status` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '状态1:启用,0:禁用',
  `tips` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '鼠标悬停提示信息',
  `url` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '链接',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UK_s37unj3gh67ujhk83lqva8i1t`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '菜单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_menu
-- ----------------------------
INSERT INTO `t_sys_menu` VALUES (1, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'system', 'fa-cog', '1', '1', '1', '系统管理', '4', '0', '[0],', '1', NULL, '/system');
INSERT INTO `t_sys_menu` VALUES (2, 1, '2019-07-31 22:04:30', 1, '2019-03-11 22:25:38', 'cms', NULL, '1', NULL, '1', 'CMS管理', '5', '0', '[0],', '1', NULL, '/cms');
INSERT INTO `t_sys_menu` VALUES (3, 1, '2019-07-31 22:04:30', 1, '2019-06-02 10:09:09', 'operationMgr', NULL, '1', NULL, '1', '运维管理', '3', '0', '[0],', '1', NULL, '/optionMgr');
INSERT INTO `t_sys_menu` VALUES (4, 1, '2019-07-31 22:04:30', 1, '2019-04-16 18:59:15', 'mgr', NULL, '1', NULL, '2', '用户管理', '1', 'system', '[0],[system],', '1', NULL, '/mgr');
INSERT INTO `t_sys_menu` VALUES (5, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.add', NULL, '0', NULL, '3', '添加用户', '1', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/add');
INSERT INTO `t_sys_menu` VALUES (6, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.edit', NULL, '0', NULL, '3', '修改用户', '2', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/edit');
INSERT INTO `t_sys_menu` VALUES (7, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.delete', NULL, '0', '0', '3', '删除用户', '3', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/delete');
INSERT INTO `t_sys_menu` VALUES (8, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.reset', NULL, '0', '0', '3', '重置密码', '4', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/reset');
INSERT INTO `t_sys_menu` VALUES (9, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.freeze', NULL, '0', '0', '3', '冻结用户', '5', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/freeze');
INSERT INTO `t_sys_menu` VALUES (10, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.unfreeze', NULL, '0', '0', '3', '解除冻结用户', '6', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/unfreeze');
INSERT INTO `t_sys_menu` VALUES (11, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'mgr.set.role', NULL, '0', '0', '3', '分配角色', '7', 'mgr', '[0],[system],[mgr],', '1', NULL, '/mgr/setRole');
INSERT INTO `t_sys_menu` VALUES (12, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'role', NULL, '1', '0', '2', '角色管理', '2', 'system', '[0],[system],', '1', NULL, '/role');
INSERT INTO `t_sys_menu` VALUES (13, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'role.add', NULL, '0', '0', '3', '添加角色', '1', 'role', '[0],[system],[role],', '1', NULL, '/role/add');
INSERT INTO `t_sys_menu` VALUES (14, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'role.edit', NULL, '0', '0', '3', '修改角色', '2', 'role', '[0],[system],[role],', '1', NULL, '/role/edit');
INSERT INTO `t_sys_menu` VALUES (15, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'role.delete', NULL, '0', '0', '3', '删除角色', '3', 'role', '[0],[system],[role],', '1', NULL, '/role/remove');
INSERT INTO `t_sys_menu` VALUES (16, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'role.set.authority', NULL, '0', '0', '3', '配置权限', '4', 'role', '[0],[system],[role],', '1', NULL, '/role/setAuthority');
INSERT INTO `t_sys_menu` VALUES (17, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'menu', NULL, '1', '0', '2', '菜单管理', '4', 'system', '[0],[system],', '1', NULL, '/menu');
INSERT INTO `t_sys_menu` VALUES (18, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'menu.add', NULL, '0', '0', '3', '添加菜单', '1', 'menu', '[0],[system],[menu],', '1', NULL, '/menu/add');
INSERT INTO `t_sys_menu` VALUES (19, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'menu.edit', NULL, '0', '0', '3', '修改菜单', '2', 'menu', '[0],[system],[menu],', '1', NULL, '/menu/edit');
INSERT INTO `t_sys_menu` VALUES (20, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'menu.delete', NULL, '0', '0', '3', '删除菜单', '3', 'menu', '[0],[system],[menu],', '1', NULL, '/menu/remove');
INSERT INTO `t_sys_menu` VALUES (21, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dept', NULL, '1', NULL, '2', '部门管理', '3', 'system', '[0],[system],', '1', NULL, '/dept');
INSERT INTO `t_sys_menu` VALUES (22, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dict', NULL, '1', NULL, '2', '字典管理', '4', 'system', '[0],[system],', '1', NULL, '/dict');
INSERT INTO `t_sys_menu` VALUES (23, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dept.edit', NULL, '0', NULL, '3', '修改部门', '1', 'dept', '[0],[system],[dept],', '1', NULL, '/dept/update');
INSERT INTO `t_sys_menu` VALUES (24, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dept.delete', NULL, '0', NULL, '3', '删除部门', '1', 'dept', '[0],[system],[dept],', '1', NULL, '/dept/delete');
INSERT INTO `t_sys_menu` VALUES (25, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dict.add', NULL, '0', NULL, '3', '添加字典', '1', 'dict', '[0],[system],[dict],', '1', NULL, '/dict/add');
INSERT INTO `t_sys_menu` VALUES (26, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dict.edit', NULL, '0', NULL, '3', '修改字典', '1', 'dict', '[0],[system],[dict],', '1', NULL, '/dict/update');
INSERT INTO `t_sys_menu` VALUES (27, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dict.delete', NULL, '0', NULL, '3', '删除字典', '1', 'dict', '[0],[system],[dict],', '1', NULL, '/dict/delete');
INSERT INTO `t_sys_menu` VALUES (28, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dept.list', NULL, '0', NULL, '3', '部门列表', '5', 'dept', '[0],[system],[dept],', '1', NULL, '/dept/list');
INSERT INTO `t_sys_menu` VALUES (29, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dept.detail', NULL, '0', NULL, '3', '部门详情', '6', 'dept', '[0],[system],[dept],', '1', NULL, '/dept/detail');
INSERT INTO `t_sys_menu` VALUES (30, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dict.list', NULL, '0', NULL, '3', '字典列表', '5', 'dict', '[0],[system],[dict],', '1', NULL, '/dict/list');
INSERT INTO `t_sys_menu` VALUES (31, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dict.detail', NULL, '0', NULL, '3', '字典详情', '6', 'dict', '[0],[system],[dict],', '1', NULL, '/dict/detail');
INSERT INTO `t_sys_menu` VALUES (32, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'dept.add', NULL, '0', NULL, '3', '添加部门', '1', 'dept', '[0],[system],[dept],', '1', NULL, '/dept/add');
INSERT INTO `t_sys_menu` VALUES (33, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'cfg', NULL, '1', NULL, '2', '参数管理', '10', 'system', '[0],[system],', '1', NULL, '/cfg');
INSERT INTO `t_sys_menu` VALUES (34, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'cfg.add', NULL, '0', NULL, '3', '添加系统参数', '1', 'cfg', '[0],[system],[cfg],', '1', NULL, '/cfg/add');
INSERT INTO `t_sys_menu` VALUES (35, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'cfg.edit', NULL, '0', NULL, '3', '修改系统参数', '2', 'cfg', '[0],[system],[cfg],', '1', NULL, '/cfg/update');
INSERT INTO `t_sys_menu` VALUES (36, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'cfg.delete', NULL, '0', NULL, '3', '删除系统参数', '3', 'cfg', '[0],[system],[cfg],', '1', NULL, '/cfg/delete');
INSERT INTO `t_sys_menu` VALUES (37, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'task', NULL, '1', NULL, '2', '任务管理', '11', 'system', '[0],[system],', '1', NULL, '/task');
INSERT INTO `t_sys_menu` VALUES (38, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'task.add', NULL, '0', NULL, '3', '添加任务', '1', 'task', '[0],[system],[task],', '1', NULL, '/task/add');
INSERT INTO `t_sys_menu` VALUES (39, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'task.edit', NULL, '0', NULL, '3', '修改任务', '2', 'task', '[0],[system],[task],', '1', NULL, '/task/update');
INSERT INTO `t_sys_menu` VALUES (40, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'task.delete', NULL, '0', NULL, '3', '删除任务', '3', 'task', '[0],[system],[task],', '1', NULL, '/task/delete');
INSERT INTO `t_sys_menu` VALUES (41, 1, '2019-03-11 22:29:54', 1, '2019-03-11 22:29:54', 'channel', NULL, '1', NULL, '2', '栏目管理', '1', 'cms', '[0],[cms],', '1', NULL, '/channel');
INSERT INTO `t_sys_menu` VALUES (42, 1, '2019-03-11 22:30:17', 1, '2019-03-11 22:30:17', 'article', NULL, '1', NULL, '2', '文章管理', '2', 'cms', '[0],[cms],', '1', NULL, '/article');
INSERT INTO `t_sys_menu` VALUES (43, 1, '2019-03-11 22:30:52', 1, '2019-03-11 22:30:52', 'banner', NULL, '1', NULL, '2', 'banner管理', '3', 'cms', '[0],[cms],', '1', NULL, '/banner');
INSERT INTO `t_sys_menu` VALUES (44, 1, '2019-03-18 19:45:37', 1, '2019-03-18 19:45:37', 'contacts', NULL, '1', NULL, '2', '邀约管理', '4', 'cms', '[0],[cms],', '1', NULL, '/contacts');
INSERT INTO `t_sys_menu` VALUES (45, 1, '2019-03-19 10:25:05', 1, '2019-03-19 10:25:05', 'file', NULL, '1', NULL, '2', '文件管理', '5', 'cms', '[0],[cms],', '1', NULL, '/fileMgr');
INSERT INTO `t_sys_menu` VALUES (46, 1, '2019-03-11 22:30:17', 1, '2019-03-11 22:30:17', 'article.edit', NULL, '1', NULL, '3', '编辑文章', '1', 'article', '[0],[cms],[article]', '1', NULL, '/article/edit');
INSERT INTO `t_sys_menu` VALUES (47, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'task.log', NULL, '1', NULL, '3', '任务日志', '4', 'task', '[0],[system],[task],', '1', NULL, '/taskLog');
INSERT INTO `t_sys_menu` VALUES (48, 1, '2019-07-31 22:04:30', 1, '2019-06-02 10:25:31', 'log', NULL, '1', NULL, '2', '业务日志', '6', 'operationMgr', '[0],[operationMgr],', '1', NULL, '/log');
INSERT INTO `t_sys_menu` VALUES (49, 1, '2019-07-31 22:04:30', 1, '2019-06-02 10:25:36', 'login.log', NULL, '1', NULL, '2', '登录日志', '6', 'operationMgr', '[0],[operationMgr],', '1', NULL, '/loginLog');
INSERT INTO `t_sys_menu` VALUES (50, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'log.clear', NULL, '0', NULL, '3', '清空日志', '3', 'log', '[0],[system],[log],', '1', NULL, '/log/delLog');
INSERT INTO `t_sys_menu` VALUES (51, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'log.detail', NULL, '0', NULL, '3', '日志详情', '3', 'log', '[0],[system],[log],', '1', NULL, '/log/detail');
INSERT INTO `t_sys_menu` VALUES (52, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'login.log.clear', NULL, '0', NULL, '3', '清空登录日志', '1', 'loginLog', '[0],[system],[loginLog],', '1', NULL, '/loginLog/delLoginLog');
INSERT INTO `t_sys_menu` VALUES (53, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'login.log.list', NULL, '0', NULL, '3', '登录日志列表', '2', 'loginLog', '[0],[system],[loginLog],', '1', NULL, '/loginLog/list');
INSERT INTO `t_sys_menu` VALUES (54, 1, '2019-06-02 10:10:20', 1, '2019-06-02 10:10:20', 'druid', NULL, '1', NULL, '2', '数据库管理', '1', 'operationMgr', '[0],[operationMgr],', '1', NULL, '/druid');
INSERT INTO `t_sys_menu` VALUES (55, 1, '2019-06-02 10:10:20', 1, '2019-06-02 10:10:20', 'swagger', NULL, '1', NULL, '2', '接口文档', '2', 'operationMgr', '[0],[operationMgr],', '1', NULL, '/swagger');
INSERT INTO `t_sys_menu` VALUES (56, 1, '2019-06-10 21:26:52', 1, '2019-06-10 21:26:52', 'messageMgr', NULL, '1', NULL, '1', '消息管理', '5', '0', '[0],', '1', NULL, '/message');
INSERT INTO `t_sys_menu` VALUES (57, 1, '2019-06-10 21:27:34', 1, '2019-06-10 21:27:34', 'msg', NULL, '1', NULL, '2', '历史消息', '1', 'messageMgr', '[0],[messageMgr],', '1', NULL, '/history');
INSERT INTO `t_sys_menu` VALUES (58, 1, '2019-06-10 21:27:56', 1, '2019-06-10 21:27:56', 'msg.tpl', NULL, '1', NULL, '2', '消息模板', '2', 'messageMgr', '[0],[messageMgr],', '1', NULL, '/template');
INSERT INTO `t_sys_menu` VALUES (59, 1, '2019-06-10 21:28:21', 1, '2019-06-10 21:28:21', 'msg.sender', NULL, '1', NULL, '2', '消息发送者', '3', 'messageMgr', '[0],[messageMgr],', '1', NULL, '/sender');
INSERT INTO `t_sys_menu` VALUES (60, 1, '2019-06-10 21:28:21', 1, '2019-06-10 21:28:21', 'msg.clear', NULL, '1', NULL, '2', '清空历史消息', '3', 'messageMgr', '[0],[messageMgr],', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (61, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'msg.tpl.edit', NULL, '0', NULL, '3', '编辑消息模板', '1', 'msg.tpl', '[0],[messageMgr],[msg.tpl]', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (62, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'msg.tpl.delete', NULL, '0', NULL, '3', '删除消息模板', '2', 'msg.tpl', '[0],[messageMgr],[msg.tpl]', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (63, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'msg.sender.edit', NULL, '0', NULL, '3', '编辑消息发送器', '1', 'msg.sender', '[0],[messageMgr],[msg.sender]', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (64, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'msg.sender.delete', NULL, '0', NULL, '3', '删除消息发送器', '2', 'msg.sender', '[0],[messageMgr],[msg.sender]', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (65, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'file.upload', NULL, '0', NULL, '3', '上传文件', '1', 'file', '[0],[cms],[file],', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (66, 1, '2019-07-31 21:51:33', 1, '2019-07-31 21:51:33', 'banner.edit', NULL, '0', NULL, '3', '编辑banner', '1', 'banner', '[0],[cms],[banner],', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (67, 1, '2019-07-31 21:51:33', 1, '2019-07-31 21:51:33', 'banner.delete', NULL, '0', NULL, '3', '删除banner', '2', 'banner', '[0],[cms],[banner],', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (68, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'channel.edit', NULL, '0', NULL, '3', '编辑栏目', '1', 'channel', '[0],[cms],[channel],', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (69, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'channel.delete', NULL, '0', NULL, '3', '删除栏目', '2', 'channel', '[0],[cms],[channel],', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (70, 1, '2019-07-31 22:04:30', 1, '2019-07-31 22:04:30', 'article.delete', NULL, '0', NULL, '3', '删除文章', '2', 'article', '[0],[cms],[article]', '1', NULL, NULL);
INSERT INTO `t_sys_menu` VALUES (71, 1, '2021-05-14 16:49:20', NULL, NULL, 'businessMgr', '', '1', '', '1', '业务管理', '1', '0', '[0],', '1', '', '/business');
INSERT INTO `t_sys_menu` VALUES (72, 1, '2021-05-14 16:49:20', NULL, NULL, 'shop', '', '1', '', '2', '商铺管理', '2', 'businessMgr', '[0],[businessMgr],', '1', '', '/business/shop');
INSERT INTO `t_sys_menu` VALUES (73, 1, '2021-05-14 16:49:20', NULL, NULL, 'shop.add', '', '1', '', '2', '添加商铺', '1', 'businessMgr', '[0],[businessMgr],', '1', '', '/business/shop/add');
INSERT INTO `t_sys_menu` VALUES (74, 1, '2021-05-14 16:49:20', NULL, NULL, 'food', '', '1', '', '2', '食品管理', '3', 'businessMgr', '[0],[businessMgr],', '1', '', '/business/food');
INSERT INTO `t_sys_menu` VALUES (75, 1, '2021-05-14 16:49:20', NULL, NULL, 'order', '', '1', '', '2', '订单管理', '4', 'businessMgr', '[0],[businessMgr],', '1', '', '/business/order');
INSERT INTO `t_sys_menu` VALUES (76, 1, '2021-05-14 16:49:20', NULL, NULL, 'food.add', '', '1', '', '2', '添加食品', '6', 'businessMgr', '[0],[businessMgr],', '1', '', '/business/food/add');
INSERT INTO `t_sys_menu` VALUES (77, 1, '2021-05-14 16:49:20', NULL, NULL, 'shop.edit', '', '0', '', '3', '修改商铺', '1', 'shop', '[0],[businessMgr],[shop],', '1', '', '/business/shop/edit');
INSERT INTO `t_sys_menu` VALUES (78, 1, '2021-05-14 16:49:20', NULL, NULL, 'shop.delete', '', '0', '', '3', '删除商铺', '5', 'shop', '[0],[businessMgr],[shop],', '1', '', '/business/shop/delete');
INSERT INTO `t_sys_menu` VALUES (79, 1, '2021-05-14 16:49:20', NULL, NULL, 'food.edit', '', '0', '', '3', '修改食品', '1', 'food', '[0],[businessMgr],[food],', '1', '', '/business/food/edit');
INSERT INTO `t_sys_menu` VALUES (80, 1, '2021-05-14 16:49:20', NULL, NULL, 'food.delete', '', '0', '', '3', '删除食品', '2', 'food', '[0],[businessMgr],[food],', '1', '', '/business/food/delete');
INSERT INTO `t_sys_menu` VALUES (81, 1, '2021-05-14 16:49:20', NULL, NULL, 'food.audit', '', '0', '', '3', '审核食品', '3', 'food', '[0],[businessMgr],[food],', '1', '', '/business/food/audit');
INSERT INTO `t_sys_menu` VALUES (82, 1, '2021-05-14 16:49:20', NULL, NULL, 'shop.audit', '', '0', '', '3', '审核商铺', '3', 'shop', '[0],[businessMgr],[shop],', '1', '', '/business/shop/audit');
INSERT INTO `t_sys_menu` VALUES (83, 1, '2021-05-14 16:49:20', NULL, NULL, 'sdetail', '', '1', '', '2', '我的商铺', '2', 'businessMgr', '[0],[businessMgr],', '1', '', '/business/sdetail');
INSERT INTO `t_sys_menu` VALUES (84, 1, '2021-05-14 16:49:20', NULL, NULL, 'orderdetail', '', '1', '', '2', '订单详情', '2', 'orderdetail', '[0],[businessMgr],', '1', '', '/business/orderdetail');

-- ----------------------------
-- Table structure for t_sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_notice`;
CREATE TABLE `t_sys_notice`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `content` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `type` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '通知' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_notice
-- ----------------------------
INSERT INTO `t_sys_notice` VALUES (1, 1, '2017-01-11 08:53:20', 1, '2019-01-08 23:30:58', '欢迎使用flash-waimai后台管理系统', '世界', 10);

-- ----------------------------
-- Table structure for t_sys_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_operation_log`;
CREATE TABLE `t_sys_operation_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `classname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `logname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `logtype` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `message` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '详细信息',
  `method` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `succeed` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `userid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '操作日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_operation_log
-- ----------------------------
INSERT INTO `t_sys_operation_log` VALUES (1, 'cn.enilu.flash.api.controller.cms.ArticleMgrController', '2019-05-10 13:22:49', '添加参数', '业务日志', '参数名称=system.app.name', 'upload', '成功', 1);
INSERT INTO `t_sys_operation_log` VALUES (2, 'cn.enilu.flash.api.controller.cms.ArticleMgrController', '2019-06-10 13:31:09', '修改参数', '业务日志', '参数名称=system.app.name', 'upload', '成功', 1);
INSERT INTO `t_sys_operation_log` VALUES (3, 'cn.enilu.flash.api.controller.cms.ArticleMgrController', '2019-07-10 13:22:49', '编辑文章', '业务日志', '参数名称=system.app.name', 'upload', '成功', 1);
INSERT INTO `t_sys_operation_log` VALUES (4, 'cn.enilu.flash.api.controller.cms.ArticleMgrController', '2019-08-10 13:31:09', '编辑栏目', '业务日志', '参数名称=system.app.name', 'upload', '成功', 1);

-- ----------------------------
-- Table structure for t_sys_relation
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_relation`;
CREATE TABLE `t_sys_relation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `menuid` bigint(20) NULL DEFAULT NULL,
  `roleid` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 161 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '菜单角色关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_relation
-- ----------------------------
INSERT INTO `t_sys_relation` VALUES (1, 42, 1);
INSERT INTO `t_sys_relation` VALUES (2, 70, 1);
INSERT INTO `t_sys_relation` VALUES (3, 46, 1);
INSERT INTO `t_sys_relation` VALUES (4, 43, 1);
INSERT INTO `t_sys_relation` VALUES (5, 67, 1);
INSERT INTO `t_sys_relation` VALUES (6, 66, 1);
INSERT INTO `t_sys_relation` VALUES (7, 33, 1);
INSERT INTO `t_sys_relation` VALUES (8, 34, 1);
INSERT INTO `t_sys_relation` VALUES (9, 36, 1);
INSERT INTO `t_sys_relation` VALUES (10, 35, 1);
INSERT INTO `t_sys_relation` VALUES (11, 41, 1);
INSERT INTO `t_sys_relation` VALUES (12, 69, 1);
INSERT INTO `t_sys_relation` VALUES (13, 68, 1);
INSERT INTO `t_sys_relation` VALUES (14, 2, 1);
INSERT INTO `t_sys_relation` VALUES (15, 44, 1);
INSERT INTO `t_sys_relation` VALUES (16, 21, 1);
INSERT INTO `t_sys_relation` VALUES (17, 32, 1);
INSERT INTO `t_sys_relation` VALUES (18, 24, 1);
INSERT INTO `t_sys_relation` VALUES (19, 29, 1);
INSERT INTO `t_sys_relation` VALUES (20, 23, 1);
INSERT INTO `t_sys_relation` VALUES (21, 28, 1);
INSERT INTO `t_sys_relation` VALUES (22, 22, 1);
INSERT INTO `t_sys_relation` VALUES (23, 25, 1);
INSERT INTO `t_sys_relation` VALUES (24, 27, 1);
INSERT INTO `t_sys_relation` VALUES (25, 31, 1);
INSERT INTO `t_sys_relation` VALUES (26, 26, 1);
INSERT INTO `t_sys_relation` VALUES (27, 30, 1);
INSERT INTO `t_sys_relation` VALUES (28, 54, 1);
INSERT INTO `t_sys_relation` VALUES (29, 45, 1);
INSERT INTO `t_sys_relation` VALUES (30, 65, 1);
INSERT INTO `t_sys_relation` VALUES (31, 48, 1);
INSERT INTO `t_sys_relation` VALUES (32, 50, 1);
INSERT INTO `t_sys_relation` VALUES (33, 51, 1);
INSERT INTO `t_sys_relation` VALUES (34, 49, 1);
INSERT INTO `t_sys_relation` VALUES (35, 52, 1);
INSERT INTO `t_sys_relation` VALUES (36, 53, 1);
INSERT INTO `t_sys_relation` VALUES (37, 17, 1);
INSERT INTO `t_sys_relation` VALUES (38, 18, 1);
INSERT INTO `t_sys_relation` VALUES (39, 20, 1);
INSERT INTO `t_sys_relation` VALUES (40, 19, 1);
INSERT INTO `t_sys_relation` VALUES (41, 56, 1);
INSERT INTO `t_sys_relation` VALUES (42, 4, 1);
INSERT INTO `t_sys_relation` VALUES (43, 5, 1);
INSERT INTO `t_sys_relation` VALUES (44, 7, 1);
INSERT INTO `t_sys_relation` VALUES (45, 6, 1);
INSERT INTO `t_sys_relation` VALUES (46, 9, 1);
INSERT INTO `t_sys_relation` VALUES (47, 8, 1);
INSERT INTO `t_sys_relation` VALUES (48, 11, 1);
INSERT INTO `t_sys_relation` VALUES (49, 10, 1);
INSERT INTO `t_sys_relation` VALUES (50, 57, 1);
INSERT INTO `t_sys_relation` VALUES (51, 60, 1);
INSERT INTO `t_sys_relation` VALUES (52, 59, 1);
INSERT INTO `t_sys_relation` VALUES (53, 64, 1);
INSERT INTO `t_sys_relation` VALUES (54, 63, 1);
INSERT INTO `t_sys_relation` VALUES (55, 58, 1);
INSERT INTO `t_sys_relation` VALUES (56, 62, 1);
INSERT INTO `t_sys_relation` VALUES (57, 61, 1);
INSERT INTO `t_sys_relation` VALUES (58, 3, 1);
INSERT INTO `t_sys_relation` VALUES (59, 12, 1);
INSERT INTO `t_sys_relation` VALUES (60, 13, 1);
INSERT INTO `t_sys_relation` VALUES (61, 15, 1);
INSERT INTO `t_sys_relation` VALUES (62, 14, 1);
INSERT INTO `t_sys_relation` VALUES (63, 16, 1);
INSERT INTO `t_sys_relation` VALUES (64, 55, 1);
INSERT INTO `t_sys_relation` VALUES (65, 1, 1);
INSERT INTO `t_sys_relation` VALUES (66, 37, 1);
INSERT INTO `t_sys_relation` VALUES (67, 38, 1);
INSERT INTO `t_sys_relation` VALUES (68, 40, 1);
INSERT INTO `t_sys_relation` VALUES (69, 39, 1);
INSERT INTO `t_sys_relation` VALUES (70, 47, 1);
INSERT INTO `t_sys_relation` VALUES (128, 41, 2);
INSERT INTO `t_sys_relation` VALUES (129, 42, 2);
INSERT INTO `t_sys_relation` VALUES (130, 43, 2);
INSERT INTO `t_sys_relation` VALUES (131, 44, 2);
INSERT INTO `t_sys_relation` VALUES (132, 45, 2);
INSERT INTO `t_sys_relation` VALUES (133, 46, 2);
INSERT INTO `t_sys_relation` VALUES (134, 65, 2);
INSERT INTO `t_sys_relation` VALUES (135, 66, 2);
INSERT INTO `t_sys_relation` VALUES (136, 67, 2);
INSERT INTO `t_sys_relation` VALUES (137, 68, 2);
INSERT INTO `t_sys_relation` VALUES (138, 69, 2);
INSERT INTO `t_sys_relation` VALUES (139, 70, 2);
INSERT INTO `t_sys_relation` VALUES (143, 2, 2);
INSERT INTO `t_sys_relation` VALUES (144, 71, 1);
INSERT INTO `t_sys_relation` VALUES (145, 72, 1);
INSERT INTO `t_sys_relation` VALUES (146, 73, 1);
INSERT INTO `t_sys_relation` VALUES (147, 74, 1);
INSERT INTO `t_sys_relation` VALUES (148, 81, 1);
INSERT INTO `t_sys_relation` VALUES (149, 82, 1);
INSERT INTO `t_sys_relation` VALUES (150, 84, 3);
INSERT INTO `t_sys_relation` VALUES (151, 65, 3);
INSERT INTO `t_sys_relation` VALUES (152, 76, 3);
INSERT INTO `t_sys_relation` VALUES (153, 80, 3);
INSERT INTO `t_sys_relation` VALUES (154, 79, 3);
INSERT INTO `t_sys_relation` VALUES (155, 77, 3);
INSERT INTO `t_sys_relation` VALUES (156, 74, 3);
INSERT INTO `t_sys_relation` VALUES (157, 75, 3);
INSERT INTO `t_sys_relation` VALUES (158, 83, 3);
INSERT INTO `t_sys_relation` VALUES (159, 71, 3);
INSERT INTO `t_sys_relation` VALUES (160, 75, 1);

-- ----------------------------
-- Table structure for t_sys_role
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_role`;
CREATE TABLE `t_sys_role`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `deptid` bigint(20) NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `num` int(11) NULL DEFAULT NULL,
  `pid` bigint(20) NULL DEFAULT NULL,
  `tips` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `version` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '角色' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_role
-- ----------------------------
INSERT INTO `t_sys_role` VALUES (1, NULL, NULL, NULL, NULL, 24, '超级管理员', 1, 0, 'administrator', 1);
INSERT INTO `t_sys_role` VALUES (2, NULL, NULL, NULL, NULL, 25, '网站管理员', 2, 1, 'developer', NULL);
INSERT INTO `t_sys_role` VALUES (3, 1, '2021-05-14 17:04:28', NULL, NULL, NULL, '商铺人员', 3, 0, 'shop', NULL);

-- ----------------------------
-- Table structure for t_sys_task
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_task`;
CREATE TABLE `t_sys_task`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `concurrent` tinyint(4) NULL DEFAULT NULL COMMENT '是否允许并发',
  `cron` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '定时规则',
  `data` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行参数',
  `disabled` tinyint(4) NULL DEFAULT NULL COMMENT '是否禁用',
  `exec_at` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `exec_result` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行结果',
  `job_class` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行类',
  `job_group` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务组名',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务名',
  `note` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务说明',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '定时任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_task
-- ----------------------------
INSERT INTO `t_sys_task` VALUES (1, 1, '2018-12-28 09:54:00', 1, '2023-04-26 14:28:10', 0, '0 0/30 * * * ?', '{\n\"appname\": \"flash-waimai\",\n\"version\":1\n}\n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            \n            ', 1, '2019-03-27 11:47:00', '执行成功', 'cn.enilu.flash.service.task.job.HelloJob', 'default', '测试任务', '测试任务,每30分钟执行一次');

-- ----------------------------
-- Table structure for t_sys_task_log
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_task_log`;
CREATE TABLE `t_sys_task_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `exec_at` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `exec_success` int(11) NULL DEFAULT NULL COMMENT '执行结果（成功:1、失败:0)',
  `id_task` bigint(20) NULL DEFAULT NULL,
  `job_exception` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '抛出异常',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '定时任务日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_task_log
-- ----------------------------

-- ----------------------------
-- Table structure for t_sys_user
-- ----------------------------
DROP TABLE IF EXISTS `t_sys_user`;
CREATE TABLE `t_sys_user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `account` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `birthday` datetime NULL DEFAULT NULL,
  `deptid` bigint(20) NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `roleid` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `salt` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `sex` int(11) NULL DEFAULT NULL,
  `status` int(11) NULL DEFAULT NULL,
  `version` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '账号' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_sys_user
-- ----------------------------
INSERT INTO `t_sys_user` VALUES (-1, NULL, NULL, NULL, NULL, 'system', NULL, NULL, NULL, NULL, '应用系统', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `t_sys_user` VALUES (1, NULL, '2016-01-29 08:49:53', 1, '2019-03-20 23:45:24', 'admin', NULL, '2017-05-05 00:00:00', 27, 'eniluzt@qq.com', '管理员', 'b5a51391f271f062867e5984e2fcffee', '15021222222', '1', '8pgby', 2, 1, 25);
INSERT INTO `t_sys_user` VALUES (2, NULL, '2018-09-13 17:21:02', 1, '2019-01-09 23:05:51', 'developer', NULL, '2017-12-31 00:00:00', 25, 'eniluzt@qq.com', '网站管理员', 'fac36d5616fe9ebd460691264b28ee27', '15022222222', '2,', 'vscp9', 1, 1, NULL);

-- ----------------------------
-- Table structure for t_test_boy
-- ----------------------------
DROP TABLE IF EXISTS `t_test_boy`;
CREATE TABLE `t_test_boy`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `age` int(11) NULL DEFAULT NULL COMMENT '年龄',
  `birthday` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '生日',
  `has_girl_friend` tinyint(4) NULL DEFAULT NULL COMMENT '是否有女朋友',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '姓名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '男孩' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_test_boy
-- ----------------------------
INSERT INTO `t_test_boy` VALUES (1, NULL, NULL, NULL, NULL, 18, '2000-01-01', 1, '张三');

-- ----------------------------
-- Table structure for t_test_girl
-- ----------------------------
DROP TABLE IF EXISTS `t_test_girl`;
CREATE TABLE `t_test_girl`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间/注册时间',
  `modify_by` bigint(20) NULL DEFAULT NULL COMMENT '最后更新人',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `age` int(11) NULL DEFAULT NULL COMMENT '年龄',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `has_boy_friend` tinyint(4) NULL DEFAULT NULL COMMENT '是否有男朋友',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '姓名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '女孩' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_test_girl
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
