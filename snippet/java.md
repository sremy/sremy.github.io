# Java 

## Java Collections

### Collections Creation
```java
// JDK java.util.Collections
Set<T> set   = Collections.singleton(object);
List<T> list = Collections.singletonList(object);
Map<T> map   = Collections.singletonMap(object);

// JDK 
List<String> fixedSizedArrayList = Arrays.asList("A", "B"); // wrapper around the array: create a instance of java.util.Arrays.ArrayList
List<String> arrayList = Stream.of("A", "B").collect(Collectors.toList());

// JDK 9
List<String> immutableList = List.of("foo", "bar", "baz");
Set<String> immutableSet = Set.of("foo", "bar", "baz");
Map<String, String> immutableMap = Map.of("key1","value1", "key2","value2");


// Guava
List<String> arrayList = Lists.newArrayList("A", "B");
List<String> immutableList = ImmutableList.of("A", "B", "C");
Map<String, String> immutableMap = ImmutableMap.of("key1","value1", "key2","value2");
Map<String, String> mutableMap = Maps.newHashMap(ImmutableMap.of("key1","value1", "key2","value2"));
```

#### Eclipse Collections 
<https://www.eclipse.org/collections/javadoc/11.0.0/org/eclipse/collections/impl/factory/package-summary.html>
```java
// Lists: org.eclipse.collections.api.factory.Lists

// org.eclipse.collections.api.list.MutableList
List<T> list = Lists.mutable.empty();
List<T> list = Lists.mutable.of(o1, o2, o3);
// org.eclipse.collections.api.list.ImmutableList
ImmutableList<T> list = Lists.immutable.empty();
ImmutableList<T> list = Lists.immutable.of(o1, o2, o3);
// org.eclipse.collections.api.list.FixedSizeList
FixedSizeList<T> list = Lists.fixedSize.empty();
FixedSizeList<T> list = Lists.fixedSize.of(o1, o2, o3);
```
<https://www.eclipse.org/collections/javadoc/11.0.0/org/eclipse/collections/api/factory/Lists.html>


```java
// Maps: org.eclipse.collections.api.factory.Maps

// MutableMap
Map<String, String> emptyMap = Maps.mutable.empty();
Map<String, String> map = Maps.mutable.of("a", "A", "b", "B", "c", "C");
// ImmutableMap
ImmutableMap<String, String> emptyMap = Maps.immutable.empty();
ImmutableMap<String, String> map = Maps.immutable.of("a", "A", "b", "B", "c", "C");
// FixedSizeMap
FixedSizeMap<String, String> emptyMap = Maps.fixedSize.empty();
FixedSizeMap<String, String> map = Maps.fixedSize.of("a", "A", "b", "B", "c", "C");
```


### Thread safe collections
```java
List<T> syncList = Collections.synchronizedList(List<T> list)
Queue<E> concurrentQueue = new ConcurrentLinkedQueue<E>();
Map<K,V> concurrentHashMap = new ConcurrentHashMap<K,V>();

CountDownLatch countDownLatch = new CountDownLatch(count)
```

## Java Streams

### Apache Commons IO
```java
// Decorating input stream that counts the number of bytes that have passed through the stream so far. 
class org.apache.commons.io.input.CountingInputStream extends ProxyInputStream {}
// InputStream proxy that transparently writes a copy of all bytes read from the proxied stream to a given OutputStream.
class org.apache.commons.io.input.TeeInputStream extends ProxyInputStream {}
// Simple implementation of the unix "tail -f" functionality.
class org.apache.commons.io.input.Tailer implements Runnable {}


// An output stream which will retain data in memory until a specified threshold is reached, and only then commit it to disk.
// If the stream is closed before the threshold is reached, the data will not be written to disk at all.
import org.apache.commons.io.output.DeferredFileOutputStream;
OutputStream os = new DeferredFileOutputStream(int threshold, File outputFile);
OutputStream os = new DeferredFileOutputStream(int threshold, int initialBufferSize, String prefix, String suffix, File tmpDirectory);
OutputStream os = new DeferredFileOutputStream(int threshold, String prefix, String suffix, File tmpDirectory);

// An output stream which triggers an event when a specified number of bytes of data have been written to it.
// The event can be used, for example, to throw an exception if a maximum has been reached, or to switch the underlying stream type when the threshold is exceeded.
import org.apache.commons.io.output.ThresholdingOutputStream;
```

```xml
<dependency>
    <groupId>commons-io</groupId>
    <artifactId>commons-io</artifactId>
    <version>2.11.0</version>
</dependency>
```

## Utilities
```java
int hashCodeBeforeOverride = System.identityHashCode(object);
```
