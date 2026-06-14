property toolName : "App 解锁工具"

on run
	activate
	try
		set selectedApp to choose file with prompt "请选择需要处理的 App" of type {"com.apple.application-bundle"}
	on error number -128
		return
	end try
	
	my processApp(selectedApp)
end run

on open droppedItems
	activate
	
	if (count of droppedItems) is 0 then return
	
	if (count of droppedItems) is greater than 1 then
		display dialog "一次只能处理一个 App。本次将处理拖入的第一个项目。" with title toolName buttons {"取消", "继续"} default button "继续" cancel button "取消" with icon caution
	end if
	
	my processApp(item 1 of droppedItems)
end open

on processApp(appItem)
	set appPath to POSIX path of appItem
	if appPath ends with "/" then set appPath to text 1 thru -2 of appPath
	
	if appPath does not end with ".app" then
		display dialog "所选项目不是 .app 应用包。" with title toolName buttons {"好"} default button "好" with icon stop
		return
	end if
	
	try
		set appInfo to info for appItem
		set appName to name of appInfo
	on error
		display dialog "无法读取所选 App，请确认它仍然存在。" with title toolName buttons {"好"} default button "好" with icon stop
		return
	end try
	
	set warningText to "即将处理：" & appName & return & return & "路径：" & appPath & return & return & "此操作会删除该 App 的下载隔离属性。请仅继续处理你确认来源可信的 App。"
	display dialog warningText with title toolName buttons {"取消", "继续"} default button "继续" cancel button "取消" with icon caution
	
	set helperPath to POSIX path of (path to resource "unquarantine.sh")
	set commandText to quoted form of helperPath & space & quoted form of appPath
	set resultState to "fixed"
	
	try
		do shell script commandText
	on error errorMessage number errorNumber
		if errorNumber is 10 then
			set resultState to "unchanged"
		else if errorNumber is 20 then
			my showDamagedSignature(appName)
			return
		else if errorNumber is 64 then
			display dialog "所选路径不是有效的 App。" with title toolName buttons {"好"} default button "好" with icon stop
			return
		else if errorNumber is -128 then
			return
		else
			set permissionText to "当前账户无法直接修改这个 App。" & return & return & "可以调用 macOS 官方管理员授权窗口重试。密码由系统接收，本工具不会读取或保存密码。"
			try
				display dialog permissionText with title toolName buttons {"取消", "系统授权"} default button "系统授权" cancel button "取消" with icon caution
				set adminCommandText to "/usr/bin/xattr -dr com.apple.quarantine " & quoted form of appPath
				do shell script adminCommandText with administrator privileges
				try
					do shell script commandText
					set resultState to "fixed"
				on error verificationMessage number verificationNumber
					if verificationNumber is 10 then
						set resultState to "fixed"
					else if verificationNumber is 20 then
						my showDamagedSignature(appName)
						return
					else
						display dialog "隔离属性已清除，但后续验证失败：" & return & verificationMessage with title toolName buttons {"好"} default button "好" with icon stop
						return
					end if
				end try
			on error adminMessage number adminNumber
				if adminNumber is -128 then
					display dialog "你取消了系统授权，未进行修改。" with title toolName buttons {"好"} default button "好" with icon note
				else
					display dialog "处理失败：" & return & adminMessage with title toolName buttons {"好"} default button "好" with icon stop
				end if
				return
			end try
		end if
	end try
	
	if resultState is "unchanged" then
		set resultText to "无需修复：这个 App 没有下载隔离属性。"
	else
		set resultText to "处理完成：已删除这个 App 的下载隔离属性。"
	end if
	
	set dialogResult to display dialog resultText & return & return & "是否立即打开“" & appName & "”？" with title toolName buttons {"稍后打开", "立即打开"} default button "立即打开" with icon note
	if button returned of dialogResult is "立即打开" then
		do shell script "/usr/bin/open " & quoted form of appPath
	end if
end processApp

on showDamagedSignature(appName)
	set messageText to "“" & appName & "”的隔离属性已处理，但代码签名验证失败。" & return & return & "这通常表示 App 内部文件缺失或被修改，继续删除隔离属性无法修复。请从可信来源重新下载并安装完整版本。"
	display dialog messageText with title toolName buttons {"好"} default button "好" with icon stop
end showDamagedSignature
