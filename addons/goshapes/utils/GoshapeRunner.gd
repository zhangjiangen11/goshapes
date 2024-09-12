@tool
class_name GoshapeRunner

var queue: Array[GoshapeJob] = []
var run_count := 0
var is_busy := false: get = get_is_busy

func get_is_busy() -> bool:
	return queue.size() > 0 and queue[0].state < GoshapeJob.State.Done
		
		
func cancel(owner: Object) -> void:
	for i in range(queue.size() - 1, -1 , -1):
		var job = queue[i]
		if job.owner == owner:
			queue.remove_at(i)
		if job.state == GoshapeJob.State.Running:
			job_cancel(job)
			
			
func enqueue(job: GoshapeJob) -> void:
	var queue_index := -1
	for i in range(queue.size() - 1, -1, -1):
		if queue[i].state == GoshapeJob.State.Running:
			break
		if queue[i].order < job.order:
			break
		queue_index = i
	if queue_index >= 0:
		queue.insert(queue_index, job)
	else:
		queue.append(job)
		
		
func run() -> void:
	if queue.size() > 0:
		next()
	

func next() -> void:
	while queue.size() > 0 and queue[0].state >= GoshapeJob.State.Done:
		queue.pop_front()
		
	if queue.size() < 1:
		return
		
	var job = queue[0]
	if job.state == GoshapeJob.State.Running:
		return
		
	job.state = GoshapeJob.State.Running
	job.thread = Thread.new()
	job.thread.start(job_run, Thread.PRIORITY_NORMAL)
	
	
func job_run() -> void:
	if queue.size() < 1:
		return
	var job = queue[0]
	if job.state > GoshapeJob.State.Running:
		return
	job.state = GoshapeJob.State.Running
	job.run()
	while not job.has_ran and job.state == GoshapeJob.State.Running:
		OS.delay_msec(1)
	job_complete.call_deferred(job)
	
	
func job_complete(job: GoshapeJob) -> void:
	job.thread.wait_to_finish()
	job.state = GoshapeJob.State.Done
	next.call()
	
	
func job_cancel(job: GoshapeJob) -> void:
	if job.state == GoshapeJob.State.Cancelled:
		return
	job.state == GoshapeJob.State.Cancelled
